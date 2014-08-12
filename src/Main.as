package {

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.printing.PrintJob;

import spark.primitives.Rect;

public class Main extends Sprite {
        public function Main() {
            // once we're loaded, start the actual heavy lifting...
            this.loaderInfo.addEventListener(Event.COMPLETE, getImageName);
        }

        private function getImageName(e:Event=null):void
        {
            var scriptorPage:String;
            var fv:Object = stage.loaderInfo.parameters;


            // clean up our init listener...
            removeEventListener(Event.COMPLETE, getImageName);

            // so, what are we printing, chaps?
            scriptorPage = fv.scriptorPage || "'scriptorPage' not found in FlashVars";

            // and fire off a loader for our page
            loadImage(scriptorPage);
        }

        private function loadImage(imagePath:String=null):void
        {
            var imageLoader:Loader = new Loader();

            // Load our image, from a relative path
            imageLoader.load(new URLRequest(imagePath));

            // and catch the loaded event
            imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
        }

        private function imageLoaded(event:Event):void
        {
            // We're properly loaded now, so not gonna listen to anyone or anything
            event.target.removeEventListener(Event.COMPLETE, imageLoaded);

            // Pass the raw bitmap data to the printHandler
            printPrepare(event.target.content);
        }

        private function printPrepare(bitmap:Bitmap=null):void {
            var mc = new MovieClip();
            mc._width = bitmap.width;
            mc._height = bitmap.height;
            mc.cacheAsBitmap = true;
            mc.opaqueBackground = 0xFF0000;
            mc.addChild(bitmap);

            var realW:Number = mc._width;
            var realH:Number = mc._height;
            var pj:PrintJob = new PrintJob();
            var pageCount:Number = 0;
            if (pj.start()) {
                mc._x = 0;
                mc._y = 0;
                var cXscale:Number, cYscale:Number;
                if (pj.orientation.toLowerCase() != "landscape") {
                    trace('portly');
                    mc._rotation = 90;
                    mc._x = mc._width;
                    cXscale = (pj.pageWidth / realH) * 100;
                    cYscale = (pj.pageHeight / realW) * 100;
                }
                else {
                    trace('landy');
                    cXscale = (pj.pageWidth / realW) * 100;
                    cYscale = (pj.pageHeight / realH) * 100;
                }
                mc._xscale = mc._yscale = Math.min(cXscale, cYscale);
                trace(realW); trace(realH);
                var pageRect:Rectangle = new Rectangle(0, 0, realW, realH);
                if (pj.addPage(mc, pageRect)) pageCount++;
            } else {
                trace('print terminated by user');
            }
            if (pageCount > 0) pj.send();
        }
    }
}
