import dlangui;
import std.process;
import std.stdio;
import std.array;
import std.algorithm;
import std.conv;
import std.csv;
import std.typecons;
import std.range;
import std.file;
import std.path;
import std.process;
import std.parallelism;

mixin APP_ENTRY_POINT;

struct CompareFile
{
 string file;
 string platform;
 string kind;
 string fileName;
}

struct ComparedFile
{
  string actual;
  string expected;
  string compared;
  string platform;
  string kind;
  string fileName;
  string result;
}

class Compare
{

 ComparedFile[] processActuals()
 {
    auto username = environment["USER"];
    auto actualPath = "/Users/" ~ username ~ "/dev/projects/chupachupa/integration/target/screenshots/";
    auto expectedPath = "/Users/" ~ username ~ "/dev/projects/chupachupa/integration/src/test/scala/integration/e2e/screenshots/";
    auto actuals = filter!`endsWith(a.name,".png")`(dirEntries(actualPath,SpanMode.depth)).array.map!((f){
       auto parts = f.name.split("/");
       auto platform = parts[$-3];
       auto kind = parts[$-2];
       auto fileName = baseName(f);
       return CompareFile(f.name, platform, kind, fileName);
    });
    auto expected = filter!`endsWith(a.name,".png")`(dirEntries(expectedPath,SpanMode.depth)).array.map!((f){
      auto parts = f.name.split("/");
      auto platform = parts[$-3];
      auto kind = parts[$-2];
      auto fileName = baseName(f);
      return CompareFile(f.name, platform, kind, fileName);
    });
    auto filesToCompare = actuals.filter!(a => expected.map!(e => e.fileName).array.canFind(a.fileName));

   ComparedFile[] comparedFiles;

   foreach(f ; parallel(filesToCompare,1))
   {
      auto actualFile = actualPath ~ f.platform ~ "/" ~ f.kind ~ "/" ~ f.fileName;
      auto expectedFile = expectedPath ~ f.platform ~ "/" ~ f.kind ~ "/" ~ f.fileName;
      auto comparedFile = "/tmp/compared-" ~ f.platform.replace(".","-") ~ "-" ~ f.kind ~ "-" ~ f.fileName;
      auto result = executeShell("compare -metric ae " ~ actualFile ~ " " ~ expectedFile ~ " " ~ comparedFile);
      comparedFiles ~= ComparedFile(actualFile, expectedFile, comparedFile, f.platform, f.kind, f.fileName, result.output);
    }

    auto diffs = comparedFiles.filter!(f => f.result != "0").array;
    return diffs;
 }

  Widget displayDiffs(ComparedFile[] files, Widget count)
  {
       auto container = new VerticalLayout();
       container.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

       foreach(cf ; parallel(files,1)){

         TableLayout table2 = new TableLayout("TABLE2");
         table2.colCount = 5;
         table2.padding = 10;
         table2.margins = 10;

         table2.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

       auto spacer = new TextWidget(null,"         "d);
            spacer.textColor = "#2E2E2E";
            spacer.fontWeight = 800;
            spacer.fontFace = "Arial";


         auto actualTitle = new TextWidget(null,to!dstring("Actual " ~ cf.platform ~ " - " ~ cf.kind ~ " - " ~ cf.fileName ~ " - score: " ~ cf.result));
            actualTitle.textColor = "#2E2E2E";
            actualTitle.fontWeight = 800;
            actualTitle.fontFace = "Arial";
            actualTitle.fontSize = 24;

         auto expectedTitle = new TextWidget(null,to!dstring("Expected " ~ cf.platform ~ " - " ~ cf.kind ~ " - " ~ cf.fileName ~ " - score: " ~ cf.result));
            expectedTitle.textColor = "#2E2E2E";
            expectedTitle.fontWeight = 800;
            expectedTitle.fontFace = "Arial";
            expectedTitle.fontSize = 24;


          auto comparedTitle = new TextWidget(null,to!dstring("Difference - " ~ baseName(cf.compared)));
            comparedTitle.textColor = "#2E2E2E";
            comparedTitle.fontWeight = 800;
            comparedTitle.fontFace = "Arial";
            comparedTitle.fontSize = 24;

         ImageWidget actualImage;
         ImageWidget expectedImage;
         ImageWidget comparedImage;


          actualImage = ScreenshotImage().get(cf.actual);
          expectedImage = ScreenshotImage().get(cf.expected);
          comparedImage = ScreenshotImage().get(cf.compared);

           actualImage.backgroundImageId("btn_default");
           expectedImage.backgroundImageId("btn_default");
           comparedImage.backgroundImageId("btn_default");

        auto useActual = new Button(null, "Use actual"d);

         auto actualHeader = new HorizontalLayout();
           actualHeader.addChild(actualTitle);
           actualHeader.addChild(useActual);

       auto confirmText = new TextWidget(null, "using actual"d);

       useActual.click = delegate(Widget src) {
         copy(cf.actual, cf.expected);
         actualHeader.removeChild(useActual);
         actualHeader.addChild(confirmText);
         return true;
       };

          table2.addChild(expectedTitle);
          table2.addChild(spacer);
          table2.addChild(actualHeader);
          table2.addChild(spacer);
          table2.addChild(comparedTitle);

          table2.addChild(actualImage);
          table2.addChild(spacer);
          table2.addChild(expectedImage);
          table2.addChild(spacer);
          table2.addChild(comparedImage);

          container.addChild(table2);
       }

       return container;
  }

}

struct ScreenshotImage
{
  ImageWidget getResize(string imageFile, int width, int height){
    auto imageWidget = new ImageWidget();
    auto imageBuf = loadImage(imageFile);
    auto rescaledBuf = new ColorDrawBuf(width,height);
    rescaledBuf.drawRescaled(Rect(0,0,rescaledBuf.width,rescaledBuf.height), imageBuf, Rect(0,0,imageBuf.width,imageBuf.height));
    auto imageBufRef = DrawBufRef(rescaledBuf);
    auto imageDrawable = new ImageDrawable(imageBufRef);
    imageWidget.drawable = imageDrawable;
    return imageWidget;
  }

  ImageWidget get(string imageFile){
    auto imageBuf = loadImage(imageFile);
    auto img = Ref!DrawBuf(imageBuf);
  	auto drawableImg = Ref!ImageDrawable(new ImageDrawable(img));
  	auto imageWidget = new ImageWidget();
  	imageWidget.drawable = drawableImg;
  	return imageWidget;
  }
}



extern (C) int UIAppMain(string[] args) {

// create window
   Window window = Platform.instance.createWindow("StackSnap - Browserstack image comparison tool", null,WindowFlag.Resizable,1500,1000);

  ComparedFile[] diffs;

 ScrollWidget scroll = new ScrollWidget("SCROLL1");
        scroll.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);


     auto vContainer = new VerticalLayout();
      vContainer.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
     vContainer.margins = 5;
     vContainer.padding = 5;



     auto compare = new Compare();

     auto loadSnaps = new Button(null, "Load Screenshots"d);

     ComboBox combo = new ComboBox("platform", ["windows_10_chrome_51"d, "windows_10_ie_11"d, "osx_elcapitan_safari_9.1"d]);
     combo.selectedItemIndex(0);
     auto count = new TextWidget(null,"intialized..."d);

     auto controls = new HorizontalLayout();
     controls.addChild(loadSnaps);
     controls.addChild(combo);
     controls.addChild(count);


     auto snapContainer = new VerticalLayout();

     vContainer.addChild(controls);
     vContainer.addChild(snapContainer);

     combo.itemClick = delegate(Widget src, int itemIndex) {
       snapContainer.removeAllChildren();
       auto filteredDiffs = diffs.filter!(f => f.platform == to!string(combo.selectedItem)).array;
        count.text = to!dstring(filteredDiffs.length);
       auto diffContainer = compare.displayDiffs(filteredDiffs, count);
       snapContainer.addChild(diffContainer);
         return true;
     };

    loadSnaps.click = delegate(Widget src) {
      snapContainer.removeAllChildren();
      diffs = compare.processActuals();
      auto filteredDiffs = diffs.filter!(f => f.platform == to!string(combo.selectedItem)).array;
      count.text = to!dstring(filteredDiffs.length);
      auto diffContainer = compare.displayDiffs(filteredDiffs, count);
      snapContainer.addChild(diffContainer);
      return true;
    };
      scroll.contentWidget = vContainer;


     window.mainWidget = scroll;


     window.show();
         return Platform.instance.enterMessageLoop();
}