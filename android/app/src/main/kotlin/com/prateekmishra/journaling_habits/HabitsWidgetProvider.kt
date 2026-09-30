package com.prateekmishra.journaling_habits

import android.content.Context
import android.widget.RemoteViews
import org.json.JSONObject

/** Habit success: this month's completion, today's ticks, streak, 7-day trend, top habits. */
class HabitsWidgetProvider : PaperWidgetProvider() {
    override val dataKey = "habits_data"
    override val tab = "habits"

    override fun layoutFor(size: WidgetSize) = when (size) {
        WidgetSize.SMALL -> R.layout.habits_widget_small
        WidgetSize.MEDIUM -> R.layout.habits_widget_medium
        WidgetSize.LARGE -> R.layout.habits_widget_large
    }

    override fun bind(
        ctx: Context, v: RemoteViews, size: WidgetSize, d: JSONObject, p: Palette, wDp: Float, hDp: Float,
    ) {
        val pct = d.optInt("monthPct", 0)
        val done = d.optInt("todayDone", 0)
        val total = d.optInt("todayTotal", 0)
        val streak = d.optInt("bestStreak", 0)
        val week = d.optJSONArray("week").doubles()
        val labels = d.optJSONArray("weekLabels").strings()

        when (size) {
            WidgetSize.SMALL -> {
                v.text(R.id.title, "HABITS", p.inkSoft)
                v.text(R.id.pct, "$pct%", p.ink)
                v.text(R.id.sub, "TODAY $done/$total", p.ink)
                v.setImageViewBitmap(R.id.chart, WidgetDraw.bars(ctx, wDp - 28, 34f, week, 100.0, labels, p))
            }
            WidgetSize.MEDIUM -> {
                v.text(R.id.title, "HABITS · THIS MONTH", p.inkSoft)
                v.text(R.id.pct, "$pct%", p.ink)
                v.text(R.id.sub, "TODAY $done/$total", p.ink)
                v.text(R.id.sub2, "BEST STREAK ${streak}D", p.inkSoft)
                v.setImageViewBitmap(
                    R.id.chart,
                    WidgetDraw.bars(ctx, (wDp - 38) * .55f, hDp - 28, week, 100.0, labels, p),
                )
            }
            WidgetSize.LARGE -> {
                v.text(R.id.title, "HABITS", p.inkSoft)
                v.text(R.id.sub, d.optString("month", ""), p.ink)
                v.text(R.id.s1v, "$pct%", p.ink)
                v.text(R.id.s1l, "THIS MONTH", p.inkSoft)
                v.text(R.id.s2v, "$done/$total", p.ink)
                v.text(R.id.s2l, "TODAY", p.inkSoft)
                v.text(R.id.s3v, "${streak}D", p.ink)
                v.text(R.id.s3l, "BEST STREAK", p.inkSoft)
                v.setImageViewBitmap(R.id.chart, WidgetDraw.bars(ctx, wDp - 28, 64f, week, 100.0, labels, p))
                val top = d.optJSONArray("top")
                val names = intArrayOf(R.id.n1, R.id.n2, R.id.n3, R.id.n4, R.id.n5)
                val counts = intArrayOf(R.id.c1, R.id.c2, R.id.c3, R.id.c4, R.id.c5)
                val bars = intArrayOf(R.id.bar1, R.id.bar2, R.id.bar3, R.id.bar4, R.id.bar5)
                for (i in 0 until 5) {
                    val row = top?.optJSONObject(i)
                    v.text(names[i], row?.optString("name", "") ?: "", p.ink)
                    v.text(counts[i], if (row == null) "" else "${row.optInt("count")}D", p.ink)
                    v.setImageViewBitmap(
                        bars[i],
                        WidgetDraw.progress(ctx, wDp - 28, 8f, (row?.optInt("pct", 0) ?: 0) / 100.0, p),
                    )
                }
            }
        }
    }
}
