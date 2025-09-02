package app.aventurine.scanit

import android.media.Image
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CONVERTER_CHANNEL = "app.aventurine.scanit/converter"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CONVERTER_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "yuv420888ToNv21") {
                val nv21ByteArray = yuv420888ToNv21(
                    width = call.argument<Int>("width")!!,
                    height = call.argument<Int>("height")!!,
                    planes = call.argument<List<ByteArray>>("planes")!!,
                )
                result.success(nv21ByteArray)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun yuv420888ToNv21(
        width: Int,
        height: Int,
        planes: List<ByteArray>
    ): ByteArray {
        val y = planes[0]
        val u = planes[1]
        val v = planes[2]
        val ySize = width * height
        val uvSize = width * height / 2
        val nv21 = ByteArray(ySize + uvSize)
        System.arraycopy(y, 0, nv21, 0, ySize)
        var pos = ySize
        for (i in 0 until uvSize step 2) {
            nv21[pos++] = v[i / 2]
            nv21[pos++] = u[i / 2]
        }
        return nv21
    }
}
