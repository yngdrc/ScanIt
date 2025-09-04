package app.aventurine.scanit

import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import android.media.Image
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CONVERTER_CHANNEL = "app.aventurine.scanit/converter"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CONVERTER_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getBitmapData") {
                val nv21ByteArray = getBitmapData(
                    width = call.argument<Int>("width")!!,
                    height = call.argument<Int>("height")!!,
                    nv21 = call.argument<ByteArray>("nv21")!!
                )
                result.success(nv21ByteArray)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getBitmapData(
        width: Int,
        height: Int,
        nv21: ByteArray
    ): ByteArray {
        val yuvImage = YuvImage(nv21, ImageFormat.NV21, width, height, null)
        val out = ByteArrayOutputStream()
        yuvImage.compressToJpeg(Rect(0, 0, width, height), 100, out)
        return out.toByteArray()
    }
}
