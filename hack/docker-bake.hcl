group "default" {
  targets = [
    "3_0_3",
  ]
}

target "build-dockerfile" {
  dockerfile = "Dockerfile"
}

target "build-platforms" {
  platforms = ["linux/amd64", "linux/aarch64"]
}

target "build-common" {
  pull = true
}

variable "REGISTRY_CACHE" {
  default = "ghcr.io/n0rthernl1ghts/proxmox-qdevice-cache"
}

######################
# Define the functions
######################

# Get the arguments for the build
function "get-args" {
  params = [corosync_qnetd_version, debian_distro]
  result = {
    COROSYNC_QNETD_VERSION = corosync_qnetd_version
    DEBIAN_DISTRO =  notequal(debian_distro, "") ? debian_distro : "trixie"
  }
}

# Get the cache-from configuration
function "get-cache-from" {
  params = [version]
  result = [
    "type=registry,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get the cache-to configuration
function "get-cache-to" {
  params = [version]
  result = [
    "type=registry,mode=max,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get list of image tags and registries
# Takes a version and a list of extra versions to tag
# eg. get-tags("1.19.0", ["0.19", "latest"])
function "get-tags" {
  params = [version, extra_versions]
  result = concat(
    [
      "ghcr.io/n0rthernl1ghts/proxmox-qdevice:${version}"
    ],
    flatten([
      for extra_version in extra_versions : [
        "ghcr.io/n0rthernl1ghts/proxmox-qdevice:${extra_version}"
      ]
    ])
  )
}

##########################
# Define the build targets
##########################

target "3_0_3" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("3.0.3")
  cache-to   = get-cache-to("3.0.3")
  tags       = get-tags("3.0.3", ["3", "3.0", "latest", "release"])
  args       = get-args("3.0.3", "trixie")
}