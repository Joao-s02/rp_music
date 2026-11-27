package com.ryanheise.just_audio;

import androidx.media3.common.C;
import androidx.media3.common.audio.AudioProcessor.AudioFormat;
import androidx.media3.common.audio.BaseAudioProcessor;
import androidx.media3.common.util.UnstableApi;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/** A separate filter history for each decoded stream (including crossfade). */
@UnstableApi
public final class RpEqualizerProcessor extends BaseAudioProcessor {
    private static final class Band {
        final double hz;
        final double gain;
        final double q;

        Band(double hz, double gain, double q) {
            this.hz = hz;
            this.gain = gain;
            this.q = q;
        }
    }

    private static final class Settings {
        final List<Band> bands;
        final double preamp;
        final double balance;
        final boolean limiter;

        Settings(List<Band> bands, double preamp, double balance, boolean limiter) {
            this.bands = bands;
            this.preamp = preamp;
            this.balance = balance;
            this.limiter = limiter;
        }
    }

    private static final double PEAK_CEILING = 31128; // 0.95 of signed PCM full scale.
    private static final Settings BYPASS = new Settings(Collections.emptyList(), 0, 0, false);
    private static volatile Settings settings = BYPASS;

    private Settings current;
    private List<Biquad> filters = Collections.emptyList();
    private double inputGain;
    private double left;
    private double right;
    private double release;
    private double limiterGain = 1;
    private double[] frame;

    public static void configure(Map<?, ?> values) {
        if (!Boolean.TRUE.equals(values.get("enabled"))) {
            settings = BYPASS;
            return;
        }
        List<Band> bands = new ArrayList<>();
        for (Object entry : (List<?>) values.get("bands")) {
            Map<?, ?> band = (Map<?, ?>) entry;
            double gain = number(band, "gain");
            if (gain != 0) bands.add(new Band(number(band, "hz"), gain, number(band, "q")));
        }
        double preamp = number(values, "preamp");
        double balance = number(values, "balance");
        boolean limiter = Boolean.TRUE.equals(values.get("limiter"));
        settings = bands.isEmpty() && preamp == 0 && balance == 0 && !limiter
                ? BYPASS : new Settings(Collections.unmodifiableList(bands), preamp, balance, limiter);
    }

    private static double number(Map<?, ?> values, String key) {
        return ((Number) values.get(key)).doubleValue();
    }

    @Override
    protected AudioFormat onConfigure(AudioFormat format) {
        return format.encoding == C.ENCODING_PCM_16BIT ? format : AudioFormat.NOT_SET;
    }

    @Override
    protected void onFlush() {
        current = null;
        limiterGain = 1;
    }

    private void update(Settings next) {
        current = next;
        int channels = inputAudioFormat.channelCount;
        int sampleRate = inputAudioFormat.sampleRate;
        filters = new ArrayList<>();
        for (Band band : next.bands) {
            if (band.hz < sampleRate * 0.49) filters.add(new Biquad(band, sampleRate, channels));
        }
        inputGain = Math.pow(10, next.preamp / 20);
        left = 1 - Math.max(0, next.balance);
        right = 1 + Math.min(0, next.balance);
        release = Math.exp(-1.0 / (0.05 * sampleRate));
        limiterGain = 1;
        frame = new double[channels];
    }

    @Override
    public void queueInput(ByteBuffer input) {
        Settings next = settings;
        ByteBuffer output = replaceOutputBuffer(input.remaining());
        if (next != current) update(next);
        if (next == BYPASS) {
            output.put(input);
        } else {
            input.order(ByteOrder.LITTLE_ENDIAN);
            output.order(ByteOrder.LITTLE_ENDIAN);
            int channels = frame.length;
            while (input.remaining() >= channels * Short.BYTES) {
                double peak = 0;
                for (int channel = 0; channel < channels; channel++) {
                    double sample = input.getShort() * inputGain;
                    for (int index = 0; index < filters.size(); index++) {
                        sample = filters.get(index).apply(sample, channel);
                    }
                    if (channels == 2) sample *= channel == 0 ? left : right;
                    frame[channel] = sample;
                    peak = Math.max(peak, Math.abs(sample));
                }
                if (next.limiter) {
                    double target = peak > PEAK_CEILING ? PEAK_CEILING / peak : 1;
                    limiterGain = Math.min(target, 1 - (1 - limiterGain) * release);
                }
                for (double sample : frame) {
                    double limited = sample * limiterGain;
                    output.putShort((short) Math.round(Math.max(-32768, Math.min(32767, limited))));
                }
            }
        }
        output.flip();
    }

    private static final class Biquad {
        private final double b0, b1, b2, a1, a2;
        private final double[] z1, z2;

        Biquad(Band band, int sampleRate, int channels) {
            double omega = 2 * Math.PI * band.hz / sampleRate;
            double amplitude = Math.pow(10, band.gain / 40);
            double alpha = Math.sin(omega) / (2 * band.q);
            double a0 = 1 + alpha / amplitude;
            b0 = (1 + alpha * amplitude) / a0;
            b1 = -2 * Math.cos(omega) / a0;
            b2 = (1 - alpha * amplitude) / a0;
            a1 = b1;
            a2 = (1 - alpha / amplitude) / a0;
            z1 = new double[channels];
            z2 = new double[channels];
        }

        double apply(double sample, int channel) {
            double result = b0 * sample + z1[channel];
            z1[channel] = b1 * sample - a1 * result + z2[channel];
            z2[channel] = b2 * sample - a2 * result;
            return result;
        }
    }
}
