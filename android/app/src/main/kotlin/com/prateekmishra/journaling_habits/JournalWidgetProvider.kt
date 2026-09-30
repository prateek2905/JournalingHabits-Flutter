package com.prateekmishra.journaling_habits

import android.content.Context
import android.widget.RemoteViews
import org.json.JSONObject

/** Quick access to the journal: today's date, task progress and the first few tasks. */
class JournalWidgetProvider : PaperWidgetProvider() {
    override val dataKey = "journal_data"
    override val tab = "journal"

    override fun layoutFor(size: WidgetSize) = when (size) {
        WidgetSize.SMALL -> R.layout.journal_widget_small
        WidgetSize.MEDIUM -> R.layout.journal_widget_medium
        WidgetSize.LARGE -> R.layout.journal_widget_large
    }

    override fun bind(
        ctx: Context, v: RemoteViews, size: WidgetSize, d: JSONObject, p: Palette, wDp: Float, hDp: Float,
    ) {
        val done = d.optInt("tasksDone", 0)
        val total = d.optInt("tasksTotal", 0)
        val date = d.optString("date", "TODAY")
        val prog = if (total == 0) "NO TASKS YET" else "$done/$total DONE"
        val tasks = d.optJSONArray("tasks")

        fun task(i: Int): String {
            val t = tasks?.optJSONObject(i) ?: return ""
            return (if (t.optBoolean("done")) "✕ " else "○ ") + t.optString("text", "")
        }

        fun taskColor(i: Int) = if (tasks?.optJSONObject(i)?.optBoolean("done") == true) p.inkSoft else p.ink

        val empty = "ADD TODAY'S FIRST TASK"
        when (size) {
            WidgetSize.SMALL -> {
                v.text(R.id.title, "JOURNAL", p.inkSoft)
                v.text(R.id.day, d.optInt("day", 0).toString(), p.ink)
                v.text(R.id.sub, date.substringBefore(" ·"), p.ink)
                v.text(R.id.prog, prog, p.ink)
                v.text(R.id.cta, "TAP TO WRITE ✎", p.inkSoft)
            }
            WidgetSize.MEDIUM -> {
                v.text(R.id.title, "JOURNAL", p.inkSoft)
                v.text(R.id.day, d.optInt("day", 0).toString(), p.ink)
                v.text(R.id.sub, date.substringBefore(" ·"), p.ink)
                v.text(R.id.prog, prog, p.ink)
                v.text(R.id.cta, "TAP TO WRITE ✎", p.inkSoft)
                val ids = intArrayOf(R.id.t1, R.id.t2, R.id.t3)
                for (i in ids.indices) v.text(ids[i], task(i), taskColor(i))
                if (total == 0) v.text(R.id.t2, empty, p.inkSoft)
            }
            WidgetSize.LARGE -> {
                v.text(R.id.title, "JOURNAL", p.inkSoft)
                v.text(R.id.sub, date, p.ink)
                v.text(R.id.prog, prog, p.ink)
                val ids = intArrayOf(R.id.t1, R.id.t2, R.id.t3, R.id.t4, R.id.t5)
                for (i in ids.indices) v.text(ids[i], task(i), taskColor(i))
                if (total == 0) v.text(R.id.t1, empty, p.inkSoft)
                v.text(R.id.moments, "${d.optInt("moments", 0)} MOMENTS TODAY", p.inkSoft)
                v.text(R.id.cta, "TAP TO WRITE ✎", p.ink)
            }
        }
    }
}
