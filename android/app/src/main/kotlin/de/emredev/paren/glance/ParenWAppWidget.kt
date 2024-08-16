package de.emredev.paren.glance

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import de.emredev.paren.MainActivity
import es.antonborri.home_widget.actionStartActivity

class ParenWAppWidget : GlanceAppWidget() {

    /** Needed for Updating */
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent { GlanceContent(context, currentState()) }
    }

    @Composable
    private fun GlanceContent(context: Context, currentState: HomeWidgetGlanceState) {
        val data = currentState.preferences

        val priceString = data.getString("price_string", "") ?: "1.00¥ → 0.01€"
        val priceReString = data.getString("price_restring", "") ?: "1.00€ → 160.33¥"
        val priceDatum = data.getString("price_datum", "") ?: "11.08.2024 15:29"

        Box(
            modifier =
            GlanceModifier.background(Color.White)
                .padding(16.dp)
                .clickable(onClick = actionStartActivity<MainActivity>(context))) {
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.Vertical.Top,
                horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
            ) {
                Text("😄",
                    style =
                    TextStyle(fontSize = 22.sp,
                        fontWeight = FontWeight.Bold,
                        textAlign = TextAlign.Center))
                Spacer(
                    modifier =
                    GlanceModifier.defaultWeight())
                Column(
                    verticalAlignment = Alignment.Vertical.Top,
                    horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
                    ) {
                    Text(
                        priceString,
                        style =
                        TextStyle(fontSize = 18.sp,
                            textAlign = TextAlign.Center))
                    Text(
                        priceReString,
                        style =
                        TextStyle(fontSize = 18.sp,
                            textAlign = TextAlign.Center))
                }
                Spacer(modifier = GlanceModifier.defaultWeight())
                Text(
                    priceDatum,
                    style = TextStyle(fontSize = 14.sp,
                        textAlign = TextAlign.Center))
            }
        }
    }
}