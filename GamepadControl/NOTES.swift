/**
 
 This implementation is going to be very specific to Ableton Live (hereto refered to as "Live")
 
 ## AbletonOSC (control script)
 - Download and unzipped to Live's User Library under a "Remote Scripts" folder
 - Receives and sends info about Live as OSC messages on the network
 - Select AbletonOSC as a Control Surface in Live's settings
 
 Things that can be listened for:
 - Changes for any Parameter property
    /live/device/start_listen/parameter/value <track_index> <device index> <parameter_index>
 - Changes to any Track property
    /live/song/start_listen/<property>
 - Current beat, each beat
    /live/song/start_listen/beat
 - Selected scene
    /live/view/start_listen/selected_scene
 - Selected track
    /live/view/start_listen/selected_track
 
 ## OSCKit (package)
 - Install with url in Xcode project's package dependencies
 - Used to send and receive OSC messages
 - Send to a specific address and something will happen in Live, or it will send you something back
 - Parse received messages to update state of our app
 - I think we can eventually learn to work with sockets (built-in) to make communication a little more seemless
 
 ## Local API (code)
 - Sending and receiving commands between Live
 - When our app wants to perform an action it will call a command from this API
 
 --------- -------- --------- --------
 
 # Scratch Pad
 
 - How many tracks are there?
 - Can we instantiate a class for each track and sync states?
 
 */
