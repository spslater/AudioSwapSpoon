# AudioSwap.Spoon
Hammerspoon Spoon that lets you cycle thru audio outputs.

## Useage
``` lua
hs.loadSpoon("AudioSwap")
spoon.AudioSwap:bindHotkeys({
    swap={{"cmd", "alt", "ctrl"}, "g"},
    add={{"cmd", "alt", "ctrl"}, "t"},
    del={{"cmd", "alt", "ctrl"}, "b"},
})
spoon.AudioSwap:addDevice("External Headphones"):addDevice("Mac mini Speakers")
```

### AudioSwap:addDevice(name)
Add device to swap between
- Parameters
  * name - name of device to add
- Returns
  * The AudioSwap object

### AudioSwap:bindHotkeys(mapping)
Binds hotkeys for AudioSwap
- Parameters
  * mapping - A table containing hotkey modifier/key details for the following items:
    * swap - swaping hotkey
    * add  - add new device to rotation
    * del  - delete existing device from rotation
- Returns
  * The AudioSwap object

## Links
* [Github](https://github.com/spslater/AudioSwapSpoon)

## Contributing
Help is greatly appreciated.
First check if there are any issues open that relate to what you want to help with.
Also feel free to make a pull request with changes / fixes you make.

## License
[MIT License](https://opensource.org/licenses/MIT)
