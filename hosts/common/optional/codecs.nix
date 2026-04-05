# System-level codec support: VA-API hardware decoding + GStreamer plugin sets
{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # Intel VA-API driver (Gen 8+ / Broadwell and newer)
      intel-media-driver
      # AMD VA-API driver (Mesa — covers GCN and newer)
      mesa
      # RADV Vulkan driver (AMD — used by VA-API via radeonsi/RADV path)
      amdvlk
      # VA-API → VDPAU bridge (for apps that use VDPAU)
      libvdpau-va-gl
      # Software VA-API fallback / VDPAU → VA-API bridge
      vaapiVdpau
    ];
  };

  environment.systemPackages = with pkgs; [
    # GStreamer plugin sets — covers H.264, H.265, VP8, VP9, AV1, Opus, AAC, etc.
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav    # ffmpeg bridge for GStreamer
    gst_all_1.gst-vaapi    # VA-API hardware decoding for GStreamer

    # Diagnostic tool to verify VA-API is working
    libva-utils
  ];
}
