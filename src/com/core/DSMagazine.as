package com.core{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.*;
	import com.greensock.loading.core.DisplayObjectLoader;
	import com.greensock.loading.core.LoaderCore;
	import flash.display.DisplayObject;
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
		private var currentPage:int = 0;
		private var configs:XMLList;
		private var chapters:XMLList;
		private var loader:LoaderMax = new LoaderMax({name:"pagesLoaded",onProgress:progressHandler});//, onComplete:completeHandler, onError:errorHandler
		private var queue:LoaderCore;
		private var currentChapter:int = 0;
		private var lastPage:int = 0;
		private var totalPages = 0;

		/// CONSTRUCTOR CALL FUNCTION INIT
		public function DSMagazine(){
			this.init();
		}
		
		/// ProgressHandler
		private function progressHandler(event:LoaderEvent):void {
			trace("progress: " + event.target.progress);
		}
		
		/// completeHandler
		function completeHandler(event:LoaderEvent):void {
			//var image:ContentDisplay = LoaderMax.getContent("1");
			//TweenLite.to(image, 1, {alpha:1, y:100});
			trace(event.target + " is complete!");
		}
		 
		/// errorHandler
		function errorHandler(event:LoaderEvent):void {
			trace("error occured with " + event.target + ": " + event.text);
		}
		
		
		/// LOAD XML
		private function init():void {
			var xmlLoader:XMLLoader = new XMLLoader("configs/book.xml", {onComplete:_xmlCompleteHandler});
			xmlLoader.load();
		}

		/// XML HANDLER
		/// SETTINGS CONFIGS AND PAGES IN VARIABLES
		private function _xmlCompleteHandler(event:LoaderEvent):void {
			configs = event.target.content.configs;
			chapters = event.target.content.book.chapter;

			_pageBounds = new Rectangle(0, 0, Number(configs.screen.@width), Number(configs.screen.@height));
			totalPages = configs.chapters.@pages; 
			_container = new Sprite();
			
			_container.x = _pageBounds.x;
			_container.y = _pageBounds.y;
			addChildAt(_container, 0);
			_container.addEventListener(MouseEvent.MOUSE_DOWN, _mouseDownHandler, false, 0, true);
			_pageCount = chapters.page.length();
			//trace("TotalPaginas:"+_pageCount);

			this._pageCurrent(0);
			//feel free to add a PROGRESS event listener to the LoaderMax instance to show a loading progress bar. 
			
		}
		
		/// UNLOAD PAGE INDIVIDUAL
		private function _pageUnload(page:int):void {
			trace("INFO DESLOADER:" + LoaderMax.getLoader(String(page)));
			//queue.unload();
			//trace("PAGINA ATUAL" + currentPage);
			//trace("PAG ANTERIOR:"+_container.getChildByName(String(page)) as int);
			if (page > 2) {
				if(lastPage <= page){
					page--;
					page--;
					page--;
					}else {
						page++;
						page++;
						page++;
					}
					var remover:Sprite = _container.getChildByName(String(page)) as Sprite;
					//loader[page].unload();
					//_container.getChildByName(String(page));
				try {
					remover.parent.removeChild(remover);
					//loader.getLoader(page).unload();
					
				}catch (err:Error){}
				//trace("DESCARREGAR" + page);
				
				//_container.removeChild
				//_container.removeChildAt(0);
			}
			
		}
		
		/// SETTING CURRENT CHAPTER
		private function _setChapter(numero):void {
			
			if (numero == 1) {
				currentChapter = numero;
				
				//_pageCount = chapters[currentChapter].page.length();
				_pageCount = chapters.page.length();
				//_pageCurrent();
				//trace("entrei");
			}else {
				currentChapter = numero;
			}
		}
		
		private function _pageLoad(pageId:int):void {
			
			LoaderMax.activate([ImageLoader, SWFLoader, XMLLoader]);
			queue = LoaderMax.parse("assets/" + chapters.page[pageId].@file, { name:pageId, x:pageId * _pageBounds.width, width:_pageBounds.width, height:_pageBounds.height, container:_container, onProgress:progressHandler, onComplete:completeHandler, onError:errorHandler},loader);//autoDispose:true
			
			//loader.load();/// PARADO AQUI.
			queue.load();
			
			//if (loader.status == LoaderStatus.COMPLETED) {
			//	trace("done!");
			//}
			
			//var loaded:Array = queue.getChildrenByStatus(LoaderStatus.COMPLETED);
			//trace(queue.unload() + " loaders have completed");
			/*
			switch (String(chapters.page[pageId].@type)){
			   case "image" :
			   loader.append( new ImageLoader("assets/" + chapters.page[pageId].@file, {name:pageId, x:pageId * _pageBounds.width, width:_pageBounds.width, height:_pageBounds.height, container:_container}) );
			   break;
			   
			   case "swf" :
			   loader.append( new SWFLoader("assets/" + chapters.page[pageId].@file, {name:pageId, x:pageId * _pageBounds.width, width:_pageBounds.width, height:_pageBounds.height, container:_container}) );
			   break;
			}
			*/
			//loader.load();
			//loader.load();
			//trace("INFO LOADER:" + LoaderMax.getLoader(String(pageId)));
			//return queue;
		}
		
		private function _pageCurrent(page:int):void {
			
			this._pageUnload(page);
			var i:int = -1;
			
			/// KEEP 3 PAGES LOADED.
			var paginaLoad:int;
			for (i; i < 3; i++) {
				paginaLoad = page + i;
				
				if (_container.getChildByName(String(paginaLoad)) == null && paginaLoad < totalPages) { 
					//trace("NOT LOADED");
					if (page == 0) {
						this._pageLoad(0);
						this._pageLoad(1);
						this._pageLoad(2);
					}
					if (page != 0) {
							trace("PaginalOad" + paginaLoad+"totalPAges:"+totalPages);
							this._pageLoad(paginaLoad);
					}
				}else { 
					//trace("ALREADY LOADED" + queue.name);
				}
			}
			
			
		}
		
		private function _mouseDownHandler(event:MouseEvent):void {
			
			TweenLite.killTweensOf(_container);
			_x1 = _x2 = this.mouseX;
			_t1 = _t2 = getTimer();
			_container.startDrag(false, new Rectangle(_pageBounds.x - 99999, _pageBounds.y, 9999999, 0));
			this.stage.addEventListener(MouseEvent.MOUSE_UP, _mouseUpHandler, false, 0, true);
			this.addEventListener(Event.ENTER_FRAME, _enterFrameHandler, false, 0, true);
			//trace("x="+ _pageBounds.x +"y="+_pageBounds.y+"w="+_container.width+"h="+_container.height);
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
				lastPage = _currentPageIndex;
				_currentPageIndex--;

				//trace("PAGATUAL: " + _currentPageIndex);
				
			} else if (_currentPageIndex < _pageCount - 1 && (xVelocity < -20 || _container.x < (_currentPageIndex + 0.5) * -_pageBounds.width + _pageBounds.x)) {
				lastPage = _currentPageIndex;
				_currentPageIndex++;
				
				//trace("FIM:");
				//trace(_currentPageIndex+"::"+_pageCount);
				//if (_currentPageIndex+1 == 3) {
					/// CARREGAR NOVO CAPITULO
					//this._setChapter(1);
				//}
			}
			TweenLite.to(_container, 0.9, { x:_currentPageIndex * -_pageBounds.width + _pageBounds.x, ease:Strong.easeOut } );
			
			this._pageCurrent(_currentPageIndex);
			//trace("NUMERO PAGINA ATUAL: "+_currentPageIndex);
		}

	}
}