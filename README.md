<img align="left" src="https://codeberg.org/Vxrpenter/smurf-fix/raw/branch/main/assets/example.png" width=120>

<br/><br/><br/><br/>
<div align="left">
    <h1>Smurf Fix</h1>
</div>

Are you experiencing inverted colors in Star Citizen... then you might have been another victim to the smurf bug.
Now you only have 2 options:
1. Embrace the reality of being in smurf land
2. Employ a fix (or fixes, as you like)

## The SCRIPT

You can go the easy route and just use the `smurf-fixs.sh` script which was developed through a lot of collaboration efforts on the [LUG Discord](https://discord.com/invite/meCFYPj)

**Run using commands:**
```sh
sudo sh -c "$(curl -fsSL https://codeberg.org/Vxrpenter/smurf-fix/raw/branch/main/smurf_fix.sh)"
```

Or download [here](https://codeberg.org/Vxrpenter/smurf-fix/raw/branch/main/smurf_fix.sh) / download from source:**
```sh
cd ~/Downloads/
git clone https://codeberg.org/Vxrpenter/smurf-fix/
mv ~/Downloads/smurf-fix/smurf-fix.sh ~/Downloads/
rm -rf ~/Downloads/smurf-fix/
chmod +x smurf-fix.sh
./smurf-fix.sh
```

## Other Options
### DX11:
This bug only happens when using the Vulkan renderer, you can just switch it back to Dx11 to fix this (which could impact your gameplay experience)

### Launchscript Option:
As pointed out by many users you can simply add `export DISPLAY=` to your sc-launch.sc to "fix" this issue (this can mess with your resolution and aspect ratio)