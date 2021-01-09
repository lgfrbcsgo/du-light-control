# DU Light Controller
This is a collection of Lua scripts for programming light sequences in the game Dual Universe.
Get the latest version from the [releases page](https://github.com/lgfrbcsgo/du-light-controller/releases).

## Tutorial
The tutorial assumes you own a Starter Kit. 
Starter Kits are available at **::pos{0,2,-1.3524,-49.6077,125.9548}**. 
(VR Outside the lag zone)

### Scripts introduction
There are three scripts for programming and controlling lights.
The Starter Kit has all three scripts installed and all elements connected already.

> Usually one would install the Sequencer script on the board, 
where the Programmer script is installed, once the sequence has been programmed.
However, for demonstration purposes both scripts are installed on separate programming boards on the Starter Kit.

![](images/starter_kit.png)

#### Programmer
The Programmer script, as the name suggests, is for programming a light sequence.

You can connect up to 9 lights to it. It also must be connected to one Databank.

Examine the connections of the programming board, which is labeled "Programmer", on the backside of the Starter Kit.

#### Extractor
The Extractor script id for extracting the light sequence from the Databank 
once you're done programming the sequence.

It must be connected to the same Databank as the Programmer script. 
It also must be connected to a screen (any type of screen).

Examine the connections of the programming board, which is labeled "Extractor", on the backside of the Starter Kit.

#### Sequencer
The Sequencer script is for playing back an extracted sequence.

It must be connected to the same lights as the Programmer script.
The lights must be connected to the programming board in the same order 
as they were connected to the programming board of the Programmer script. 

> It is usually easier to just install the Sequencer script on the programming board 
where the Programmer script was installed.

Examine the connections of the programming board, which is labeled "Sequencer", on the backside of the Starter Kit.

### Programming a sequence
**For this next section activate the programming board which is labeled "Programmer".**

The Starter Kit comes with a pre-programmed sequence. 

![](images/pattern.gif)

Press Alt+1 to play it back.

> In case you forget any of the hotkeys or have remapped your key bindings, 
you can always look them up in the Lua tab of the in-game chat.

Press Alt+1 again to exit the playback mode.

#### Navigating the sequence


![](images/navigation.png)


#### Modifying a step


#### Inserting and deleting steps

#### Copying and pasting a step

#### Replacing colors of a step

### Extracting a sequence from the Databank
![](images/extractor_output.png)

![](images/empty_sequence.png)

![](images/non_empty_sequence.png)

### Multiple programming boards
