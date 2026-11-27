package com.ryanheise.just_audio;

import android.content.Context;
import android.media.audiofx.Equalizer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Map;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngine.EngineLifecycleListener;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * JustAudioPlugin
 */
public class JustAudioPlugin implements FlutterPlugin {
    private MethodChannel channel;
    private MethodChannel equalizerChannel;
    private MainMethodCallHandler methodCallHandler;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        Context applicationContext = binding.getApplicationContext();
        BinaryMessenger messenger = binding.getBinaryMessenger();
        methodCallHandler = new MainMethodCallHandler(applicationContext, messenger);

        channel = new MethodChannel(messenger, "com.ryanheise.just_audio.methods");
        channel.setMethodCallHandler(methodCallHandler);
        equalizerChannel = new MethodChannel(messenger, "rp_music/equalizer");
        equalizerChannel.setMethodCallHandler((call, result) -> {
            if (call.method.equals("legacyFrequencies")) {
                try {
                    Equalizer equalizer = new Equalizer(0, (Integer) call.arguments);
                    try {
                        ArrayList<Integer> frequencies = new ArrayList<>();
                        for (short index = 0; index < equalizer.getNumberOfBands(); index++) {
                            frequencies.add(Math.round(equalizer.getCenterFreq(index) / 1000.0f));
                        }
                        result.success(frequencies);
                    } finally {
                        equalizer.release();
                    }
                } catch (RuntimeException error) {
                    result.error("legacy_equalizer", "Cannot read legacy frequencies", null);
                }
                return;
            }
            if (!call.method.equals("configure")) {
                result.notImplemented();
                return;
            }
            try {
                RpEqualizerProcessor.configure((Map<?, ?>) call.arguments);
                result.success(null);
            } catch (RuntimeException error) {
                result.error("equalizer", "Invalid equalizer configuration", null);
            }
        });
        @SuppressWarnings("deprecation")
        FlutterEngine engine = binding.getFlutterEngine();
        engine.addEngineLifecycleListener(new EngineLifecycleListener() {
            @Override
            public void onPreEngineRestart() {
                methodCallHandler.dispose();
                RpEqualizerProcessor.configure(Collections.emptyMap());
            }

            @Override
            public void onEngineWillDestroy() {
            }
        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodCallHandler.dispose();
        methodCallHandler = null;

        channel.setMethodCallHandler(null);
        equalizerChannel.setMethodCallHandler(null);
        RpEqualizerProcessor.configure(Collections.emptyMap());
    }
}
