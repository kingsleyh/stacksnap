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

struct ComparedFile
{
  string actual;
  string expected;
  string platform;
  string kind;
  string fileName;
}

class Compare
{

  ComparedFile[] processActuals()
  {
    return [
    ComparedFile("/Users/hendrkin/dev/projects/chupachupa/integration/target/screenshots/windows_10_chrome_51/client/about-the-business.png",
    "/Users/hendrkin/dev/projects/chupachupa/integration/src/test/scala/integration/e2e/screenshots/windows_10_chrome_51/client/about-the-business.png",
    "windows_10_chrome_51", "client", "about-the-business.png"
    ),
    ComparedFile("/Users/hendrkin/dev/projects/chupachupa/integration/target/screenshots/windows_10_chrome_51/client/nature-of-business.png",
    "/Users/hendrkin/dev/projects/chupachupa/integration/src/test/scala/integration/e2e/screenshots/windows_10_chrome_51/client/nature-of-business.png",
    "windows_10_chrome_51", "client", "nature-of-business.png"
    ),
  ComparedFile("/Users/hendrkin/dev/projects/chupachupa/integration/target/screenshots/windows_10_chrome_51/client/about-the-business.png",
        "/Users/hendrkin/dev/projects/chupachupa/integration/src/test/scala/integration/e2e/screenshots/windows_10_chrome_51/client/about-the-business.png",
        "windows_10_chrome_51", "client", "about-the-business.png"
      ),
      ComparedFile("/Users/hendrkin/dev/projects/chupachupa/integration/target/screenshots/windows_10_chrome_51/client/nature-of-business.png",
        "/Users/hendrkin/dev/projects/chupachupa/integration/src/test/scala/integration/e2e/screenshots/windows_10_chrome_51/client/nature-of-business.png",
        "windows_10_chrome_51", "client", "nature-of-business.png"
      ),
        ComparedFile("/Users/hendrkin/dev/projects/chupachupa/integration/target/screenshots/windows_10_chrome_51/client/about-the-business.png",
        "/Users/hendrkin/dev/projects/chupachupa/integration/src/test/scala/integration/e2e/screenshots/windows_10_chrome_51/client/about-the-business.png",
        "windows_10_chrome_51", "client", "about-the-business.png"
        ),
      ComparedFile("/Users/hendrkin/dev/projects/chupachupa/integration/target/screenshots/windows_10_chrome_51/client/nature-of-business.png",
        "/Users/hendrkin/dev/projects/chupachupa/integration/src/test/scala/integration/e2e/screenshots/windows_10_chrome_51/client/nature-of-business.png",
        "windows_10_chrome_51", "client", "nature-of-business.png"
      )
    ];
  }

}

struct ScreenshotImage
{
  ImageWidget get(string imageFile){
    auto imageWidget = new ImageWidget();
    auto imageBuf = loadImage(imageFile);
    auto rescaledBuf = new ColorDrawBuf(900,900);
    rescaledBuf.drawRescaled(Rect(0,0,rescaledBuf.width,rescaledBuf.height), imageBuf, Rect(0,0,imageBuf.width,imageBuf.height));
    auto imageBufRef = DrawBufRef(rescaledBuf);
    auto imageDrawable = new ImageDrawable(imageBufRef);
    imageWidget.drawable = imageDrawable;
    return imageWidget;
  }
}


extern (C) int UIAppMain(string[] args) {

// create window
    Window window = Platform.instance.createWindow("Tracksuit - easy deft editor", null,WindowFlag.Resizable,1500,1000);


 ScrollWidget scroll = new ScrollWidget("SCROLL1");
        scroll.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);


     auto vContainer = new VerticalLayout();
      vContainer.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
     vContainer.margins = 5;
     vContainer.padding = 5;



     auto compare = new Compare();




     foreach(cf ; compare.processActuals){


       TableLayout table2 = new TableLayout("TABLE2");
       table2.colCount = 3;
       table2.padding = 10;
       table2.margins = 10;
//       table2.backgroundColor = "black";


       table2.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

     auto spacer = new TextWidget(null,"         "d);
          spacer.textColor = "#2E2E2E";
          spacer.fontWeight = 800;
          spacer.fontFace = "Arial";

       auto actualTitle = new TextWidget(null,"Actual"d);
          actualTitle.textColor = "#2E2E2E";
          actualTitle.fontWeight = 800;
          actualTitle.fontFace = "Arial";

       auto expectedTitle = new TextWidget(null,"Expected"d);
          expectedTitle.textColor = "#2E2E2E";
          expectedTitle.fontWeight = 800;
          expectedTitle.fontFace = "Arial";

         auto actualImage = ScreenshotImage().get(cf.actual);
         auto expectedImage = ScreenshotImage().get(cf.expected);

         actualImage.backgroundImageId("btn_default");
         expectedImage.backgroundImageId("btn_default");

        table2.addChild(actualTitle);
        table2.addChild(spacer);
        table2.addChild(expectedTitle);
        table2.addChild(actualImage);
        table2.addChild(spacer);
        table2.addChild(expectedImage);

        vContainer.addChild(table2);
     }

      scroll.contentWidget = vContainer;


window.mainWidget = scroll;


     window.show();
         return Platform.instance.enterMessageLoop();
}