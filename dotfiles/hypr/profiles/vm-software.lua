-- VM: reduce effects and use software cursors for guest display compatibility.
hl.config({
    decoration = { shadow = { enabled = false }, blur = { enabled = false } },
    animations = { enabled = false },
    cursor = { no_hardware_cursors = 1 },
})

-- Use CPU rendering when accelerated virtual graphics are unavailable.
hl.env("LIBGL_ALWAYS_SOFTWARE", "true")
