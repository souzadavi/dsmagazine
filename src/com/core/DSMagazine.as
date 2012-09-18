package com.core{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.*;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	public class DSMagazine extends Sprite {
		//private var _pageBounds:Rectangle = new Rectangle(0, 0, 1232, 780);// Horizontal
		//private var _pageBounds:Rectangle = new Rectangle(0, 0, 800, 1232); //Vertical//ANDROID
		//private var _configs:Configs = new Configs();
		//private var _pageBounds:Rectangle = new Rectangle(0, 0, 768, 1024); //Vertical //IPAD
		private var _pageBounds:Rectangle;
		private var _container:Sprite;
		private var _currentPageIndex:int = 0;
		private var _pageCount:int;
		private var _x1:Number;
		private var _x2:Number;
		private var _t1:uint;
		private var _t2:uint;

		public function DSMagazine(){
			this.init();
		}
		
		private function init():void {
			var xmlLoader:XMLLoader = new XMLLoader("configs/book.xml", {onComplete:_xmlCompleteHandler});
			xmlLoader.load();
		}

		private function _xmlCompleteHandler(event:LoaderEvent):void {
			var configs:XMLList = event.target.content.configs;
			var chapters:XMLList = event.target.content.book.chapter;

			_pageBounds = new Rectangle(0, 0, Number(configs.screen.@width), Number(configs.screen.@height));
			_container = new Sprite();
			
			_container.x = _pageBounds.x;
			_container.y = _pageBounds.y;
			addChildAt(_container, 0);
			_container.addEventListener(MouseEvent.MOUSE_DOWN, _mouseDownHandler, false, 0, true);
			_pageCount = chapters.page.length();

			var queue:LoaderMax = new LoaderMax();

			for (var i:int = 0; i < _pageCount; i++) {
				//trace("PAGINAS CONTADAS:"+ chapters.page[i].@type);
				switch (String(chapters.page[i].@type)){
				   case "image" :
				   queue.append( new ImageLoader("assets/" + chapters.page[i].@file, {x:i * _pageBounds.width, width:_pageBounds.width, height:_pageBounds.height, container:_container}) );
				   break;
				   
				   case "swf" :
				   queue.append( new SWFLoader("assets/" + chapters.page[i].@file, {x:i * _pageBounds.width, width:_pageBounds.width, height:_pageBounds.height, container:_container}) );
				   break;
				}
			}
			//feel free to add a PROGRESS event listener to the LoaderMax instance to show a loading progress bar. 
			queue.load();
		}
		
		private function _mouseDownHandler(event:MouseEvent):void {
			TweenLite.killTweensOf(_container);
			_x1 = _x2 = this.mouseX;
			_t1 = _t2 = getTimer();
			_container.startDrag(false, new Rectangle(_pageBounds.x - 9999, _pageBounds.y, 9999999, 0));
			this.stage.addEventListener(MouseEvent.MOUSE_UP, _mouseUpHandler, false, 0, true);
			this.addEventListener(Event.ENTER_FRAME, _enterFrameHandler, false, 0, true);
		}
		
		private function _enterFrameHandler(event:Event):void {
			_x2 = _x1;
			_t2 = _t1;
			_x1 = this.mouseX;
			_t1 = getTimer();
		}
		
		private function _mouseUpHandler(event:MouseEvent):void {
			_container.stopDrag();
			this.removeEventListener(Event.ENTER_FRAME, _enterFrameHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, _mouseUpHandler);
			var elapsedTime:Number = (getTimer() - _t2) / 1000;
			var xVelocity:Number = (this.mouseX - _x2) / elapsedTime;
			//we make sure that the velocity is at least 20 pixels per second in either direction in order to advance. Otherwise, look at the position of the _container and if it's more than halfway into the next/previous panel, tween there.
			if (_currentPageIndex > 0 && (xVelocity > 20 || _container.x > (_currentPageIndex - 0.5) * -_pageBounds.width + _pageBounds.x)) {
				_currentPageIndex--;
			} else if (_currentPageIndex < _pageCount - 1 && (xVelocity < -20 || _container.x < (_currentPageIndex + 0.5) * -_pageBounds.width + _pageBounds.x)) {
				_currentPageIndex++;
			}
			TweenLite.to(_container, 0.7, {x:_currentPageIndex * -_pageBounds.width + _pageBounds.x, ease:Strong.easeOut});
		}

	}
}