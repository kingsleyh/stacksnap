import dlangui;
import std.process;
import std.stdio;
import std.array;
import std.algorithm;
import std.conv;
import std.csv;
import std.typecons;
import std.range;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {

// create window
    Window window = Platform.instance.createWindow("Tracksuit - easy deft editor", null,WindowFlag.Resizable,325,500);

     auto vContainer = new VerticalLayout();
      vContainer.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
     vContainer.margins = 5;
     vContainer.padding = 5;

     auto createTitle = new TextWidget(null,"Create a new item:"d);
          createTitle.textColor = "#2E2E2E";
          createTitle.fontWeight = 800;
          createTitle.fontFace = "Arial";

 vContainer.addChild(createTitle);


window.mainWidget = vContainer;


     window.show();
         return Platform.instance.enterMessageLoop();
}