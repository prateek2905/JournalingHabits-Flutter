package com.prateekmishra.journaling_habits

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.Typeface
import android.net.Uri
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sqrt

enum class WidgetSize { SMALL, MEDIUM, LARGE }

/** Colors pushed from Dart so the widgets follow the app's paper theme. */
class Palette(json: JSONObject?) {
    private fun c(key: String, fallback: String): Int =
        try {
            Color.parseColor(json?.optString(key, fallback) ?: fallback)
        } catch (e: Exception) {
            Color.parseColor(fallback)
        }

    val paper = c("paper", "#FFFDFCF8")
    val ink = c("ink", "#FF23241F")
    val inkSoft = c("inkSoft", "#9923241F")
    val grid = c("grid", "#33606A60")
    val hi = c("hi", "#FFB6FF2E")
    val onHi = c("onHi", "#FF23241F")
}

/**
 * Drawing helpers: the paper background and the little charts are bitmaps so the
 * widgets look like the app's grid paper without needing custom RemoteViews.
 */
object WidgetDraw {
    private const val MAX_PIXELS = 450_000f

    private fun scaled(ctx: Context, wDp: Float, hDp: Float): Triple<Int, Int, Float> {
        var s = ctx.resources.displayMetrics.density
        val px = wDp * s * hDp * s
        if (px > MAX_PIXELS) s *= sqrt(MAX_PIXELS / px)
        return Triple(max(1, (wDp * s).toInt()), max(1, (hDp * s).toInt()), s)
    }

    fun paper(ctx: Context, wDp: Float, hDp: Float, p: Palette): Bitmap {
        val (w, h, s) = scaled(ctx, wDp, hDp)
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val cv = Canvas(bmp)
        val r = 20f * s
        val clip = Path().apply {
            addRoundRect(RectF(0f, 0f, w.toFloat(), h.toFloat()), r, r, Path.Direction.CW)
        }
        cv.clipPath(clip)
        cv.drawColor(p.paper)
        val line = Paint().apply {
            color = p.grid
            strokeWidth = max(1f, s * .8f)
        }
        val step = 20f * s
        var x = step
        while (x < w) {
            cv.drawLine(x, 0f, x, h.toFloat(), line)
            x += step
        }
        var y = step
        while (y < h) {
            cv.drawLine(0f, y, w.toFloat(), y, line)
            y += step
        }
        return bmp
    }

    /** Vertical bars (values 0..max) with a one-letter label under each. */
    fun bars(
        ctx: Context, wDp: Float, hDp: Float, values: List<Double>, maxV: Double,
        labels: List<String>, p: Palette,
    ): Bitmap {
        val (w, h, s) = scaled(ctx, max(wDp, 20f), max(hDp, 20f))
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val cv = Canvas(bmp)
        val n = max(1, values.size)
        val labelH = 12f * s
        val slot = w / n.toFloat()
        val barW = slot * .58f
        val fill = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = p.hi
            style = Paint.Style.FILL
        }
        val stroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = p.ink
            style = Paint.Style.STROKE
            strokeWidth = 1.5f * s
        }
        val text = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = p.inkSoft
            textSize = 9f * s
            textAlign = Paint.Align.CENTER
            typeface = Typeface.create("sans-serif-condensed", Typeface.BOLD)
        }
        val plotH = h - labelH - 2f * s
        values.forEachIndexed { i, v ->
            val cx = slot * i + slot / 2
            val bh = if (v <= 0) 2f * s else max(3f * s, (min(v, maxV) / maxV).toFloat() * plotH)
            val rect = RectF(cx - barW / 2, plotH - bh + 1f * s, cx + barW / 2, plotH + 1f * s)
            if (v > 0) cv.drawRoundRect(rect, 3f * s, 3f * s, fill)
            cv.drawRoundRect(rect, 3f * s, 3f * s, stroke)
            cv.drawText(labels.getOrElse(i) { "" }, cx, h - 2f * s, text)
        }
        return bmp
    }

    /** Horizontal progress bar, [frac] in 0..1. */
    fun progress(ctx: Context, wDp: Float, hDp: Float, frac: Double, p: Palette): Bitmap {
        val (w, h, s) = scaled(ctx, max(wDp, 20f), hDp)
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val cv = Canvas(bmp)
        val pad = 1f * s
        val track = RectF(pad, pad, w - pad, h - pad)
        val rad = track.height() / 2
        val fill = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = p.hi }
        val stroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = p.inkSoft
            style = Paint.Style.STROKE
            strokeWidth = 1f * s
        }
        val f = frac.coerceIn(0.0, 1.0).toFloat()
        if (f > 0) {
            val right = track.left + max(track.height(), track.width() * f)
            cv.drawRoundRect(RectF(track.left, track.top, right, track.bottom), rad, rad, fill)
        }
        cv.drawRoundRect(track, rad, rad, stroke)
        return bmp
    }
}

fun JSONArray?.doubles(): List<Double> =
    if (this == null) emptyList() else List(length()) { optDouble(it, 0.0) }

fun JSONArray?.strings(): List<String> =
    if (this == null) emptyList() else List(length()) { optString(it, "") }

/**
 * Shared plumbing for the three widgets: picks a small/medium/large layout from the
 * widget's current size, draws the paper background, wires the tap-through, and
 * hands the rest to [bind].
 */
abstract class PaperWidgetProvider : HomeWidgetProvider() {
    /** SharedPreferences key holding this widget's JSON payload. */
    abstract val dataKey: String

    /** Tab opened by tapping the widget (journalinghabits://<tab>). */
    abstract val tab: String

    abstract fun layoutFor(size: WidgetSize): Int

    abstract fun bind(
        ctx: Context, v: RemoteViews, size: WidgetSize, d: JSONObject, p: Palette, wDp: Float, hDp: Float,
    )

    override fun onUpdate(
        context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) render(context, appWidgetManager, id, widgetData)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, newOptions: Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        render(context, appWidgetManager, appWidgetId, HomeWidgetPlugin.getData(context))
    }

    private fun render(ctx: Context, mgr: AppWidgetManager, id: Int, prefs: SharedPreferences) {
        val o = mgr.getAppWidgetOptions(id)
        val wDp = o.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0).let { if (it > 0) it else 250 }.toFloat()
        val hDp = o.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0).let { if (it > 0) it else 110 }.toFloat()
        val size = when {
            wDp < 180 -> WidgetSize.SMALL
            hDp < 180 -> WidgetSize.MEDIUM
            else -> WidgetSize.LARGE
        }
        val d = try {
            JSONObject(prefs.getString(dataKey, null) ?: "{}")
        } catch (e: Exception) {
            JSONObject()
        }
        val p = Palette(d.optJSONObject("theme"))

        val v = RemoteViews(ctx.packageName, layoutFor(size))
        v.setImageViewBitmap(R.id.bg, WidgetDraw.paper(ctx, wDp, hDp, p))
        v.setOnClickPendingIntent(
            R.id.root,
            HomeWidgetLaunchIntent.getActivity(ctx, MainActivity::class.java, Uri.parse("journalinghabits://$tab")),
        )
        bind(ctx, v, size, d, p, wDp, hDp)
        mgr.updateAppWidget(id, v)
    }

    protected fun RemoteViews.text(id: Int, s: String, color: Int) {
        setTextViewText(id, s)
        setTextColor(id, color)
    }
}
