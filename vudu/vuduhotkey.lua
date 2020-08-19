local vd = require(_vdreq .. "vudu")
local vdwin = require(_vdreq .. "vuduwindow")

vd.hotkey = vdwin.new({
  sequences = {},
}, {
  runHidden = true
})

function vd.hotkey:keypressed(key, scancode, isrepeat)
  for i, seq in ipairs(vd.hotkey.sequences) do
    if seq.keys[seq.active+1] == key then
      seq.active = seq.active+1
      if (seq.active == #seq.keys) then
        seq.callback()
      end
    end
  end
end

function vd.hotkey:keyreleased(key, scancode, isrepeat)
  for i, seq in ipairs(vd.hotkey.sequences) do
    for j, k in ipairs(seq.keys) do
      if j <= seq.active and key == k then seq.active = j-1 end
    end
  end
end

function vd.hotkey.addSequence(keylist, callback)
  table.insert(vd.hotkey.sequences, {
    keys = keylist,
    callback = callback,
    active = 0,
  })
end

return vd.hotkey