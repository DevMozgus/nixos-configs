# NFS mounts from the TrueNAS NAS (192.168.8.184)
{ ... }:
{
  fileSystems."/mnt/truenas" = {
    device = "192.168.8.184:/mnt/tank/media";
    fsType = "nfs";
    options = [
      "nfsvers=4.1" # drop this line if the TrueNAS share only allows NFSv3
      "nofail" # boot continues if the NAS is unreachable
      "x-systemd.automount" # mount on first access instead of at boot
      "x-systemd.idle-timeout=600" # unmount after 10 minutes idle
      "x-systemd.mount-timeout=10" # give up quickly when the NAS is offline
    ];
  };
}
