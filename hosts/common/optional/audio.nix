# PipeWire + WirePlumber audio stack with rnnoise noise suppression
{ pkgs, ... }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;

    # Creates a virtual microphone source named "rnnoise_source" that applies
    # RNNoise-based noise suppression to the default capture device.
    # Use it as: wf-recorder --audio-device rnnoise_source
    # Or set it as the default input in pavucontrol / audio settings.
    extraConfig.pipewire."99-noise-suppression" = {
      context.modules = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            node.description = "Noise Canceling source";
            media.name = "Noise Canceling source";
            filter.graph.nodes = [
              {
                type = "ladspa";
                name = "rnnoise";
                plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                label = "noise_suppressor_mono";
                control = {
                  "VAD Threshold (%)" = 50;
                  "VAD Grace Period (ms)" = 200;
                  "Retroactive VAD Grace (ms)" = 0;
                };
              }
            ];
            audio.rate = 48000;
            capture.props = {
              node.name = "capture.rnnoise_source";
              node.passive = true;
              audio.rate = 48000;
            };
            playback.props = {
              node.name = "rnnoise_source";
              media.class = "Audio/Source";
              audio.rate = 48000;
            };
          };
        }
      ];
    };
  };
}
