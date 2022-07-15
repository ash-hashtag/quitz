package com.rashstudios.quitz

import android.content.Context
import android.util.TypedValue
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.Log
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin


class ListTileNativeAdFactory(val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
            .inflate(R.layout.list_tile_native_ad, null) as NativeAdView

        with(nativeAdView) {
            val attributionViewSmall =
                findViewById<TextView>(R.id.tv_list_tile_native_ad_attribution_small)
            val attributionViewLarge =
                findViewById<TextView>(R.id.tv_list_tile_native_ad_attribution_large)

            val iconView = findViewById<ImageView>(R.id.iv_list_tile_native_ad_icon)
            val imageView = findViewById<ImageView>(R.id.iv_list_tile_native_ad_image)
            val icon = nativeAd.icon
            if (icon != null) {
                attributionViewSmall.visibility = View.VISIBLE
                attributionViewLarge.visibility = View.INVISIBLE
                iconView.setImageDrawable(icon.drawable)
            } else {
                attributionViewSmall.visibility = View.INVISIBLE
                attributionViewLarge.visibility = View.VISIBLE
            }
            this.iconView = iconView

            val images = nativeAd.images
            if (images.isNullOrEmpty())
            {
                imageView.visibility = View.INVISIBLE
            } else {
                imageView.visibility = View.VISIBLE
                val image = images.get(0)
                val scale = resources.displayMetrics.density
                fun dptopx(dp: Double): Int { return ((dp * scale + 0.5f).toInt()) }
                val params = FrameLayout.LayoutParams(dptopx(300.0 / image.scale), dptopx(300.0))
                Log.d("debug", "Params: ${params}, scale: ${image.scale}")
                params.setMargins(0, dptopx(84.0), 0, dptopx(30.0))
                params.gravity = Gravity.CENTER
                imageView.layoutParams = params
                imageView.setImageDrawable(images.get(0).drawable)
            }
            this.imageView = imageView

            val headlineView = findViewById<TextView>(R.id.tv_list_tile_native_ad_headline)
            headlineView.text = nativeAd.headline
            this.headlineView = headlineView

            val bodyView = findViewById<TextView>(R.id.tv_list_tile_native_ad_body)
            with(bodyView) {
                text = nativeAd.body
                visibility = if (nativeAd.body?.isNotEmpty() == true) View.VISIBLE else View.INVISIBLE
            }
            this.bodyView = bodyView
            setNativeAd(nativeAd)
        }

        return nativeAdView
    }
}