package com.prateekmishra.journaling_habits

import android.content.Context
import android.widget.RemoteViews
import org.json.JSONObject

/** Sleep stats: last logged night, its score, the month average and a 7-night trend. */
class SleepWidgetProvider : PaperWidgetProvider() {
    override val dataKey = "sleep_data"
    override val tab = "sleep"

    override fun layoutFor(size: WidgetSize) = when (size) {
        WidgetSize.SMALL -> R.layout.sleep_widget_small
        WidgetSize.MEDIUM -> R.layout.sleep_widget_medium
        WidgetSize.LARGE -> R.layout.sleep_widget_large
    }

    override fun bind(
        ctx: Context, v: RemoteViews, size: WidgetSize, d: JSONObject, p: Palette, wDp: Float, hDp: Float,
    ) {
        val has = d.optBoolean("hasData", false)
        val hours = if (has) String.format("%.1fH", d.optDouble("lastHours", 0.0)) else "--"
        val score = if (has) "SCORE ${d.optInt("lastScore")}" else "NO NIGHTS LOGGED"
        val last = d.optString("lastLabel", "")
        val week = d.optJSONArray("week").doubles()
        val labels = d.optJSONArray("weekLabels").strings()
        val avg = String.format(
            "AVG %.1fH · SCORE %d · %d NIGHTS",
            d.optDouble("avgHours", 0.0), d.optInt("avgScore", 0), d.optInt("nightsLogged", 0),
        )

        v.text(R.id.title, if (size == WidgetSize.SMALL) "SLEEP" else "SLEEP · LAST NIGHT", p.inkSoft)
        v.text(R.id.hours, hours, p.ink)
        v.text(R.id.sub, score, p.ink)
        when (size) {
            WidgetSize.SMALL -> v.text(R.id.sub2, last, p.inkSoft)
            WidgetSize.MEDIUM -> {
                v.text(R.id.sub2, last, p.inkSoft)
                v.setImageViewBitmap(
                    R.id.chart,
                    WidgetDraw.bars(ctx, (wDp - 38) * .55f, hDp - 28, week, 10.0, labels, p),
                )
            }
            WidgetSize.LARGE -> {
                v.text(R.id.sub2, avg, p.inkSoft)
                v.setImageViewBitmap(
                    R.id.chart,
                    WidgetDraw.bars(ctx, wDp - 28, hDp - 120, week, 10.0, labels, p),
                )
            }
        }
    }
}
