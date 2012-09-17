package com.controls {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.SimpleButton;
	import com.events.MenuItemSelecionadoEvent;
	import com.events.ControleItemSelecionadoEvent;
	
	
	public class MenuPrincipal extends MovieClip {
		public var modalMc:MovieClip = new MovieClip();
		
		private var _modal:Boolean = false;
		
		public function set modal(valor:Boolean):void{
			this._modal = valor;
			dispatchEvent(new Event('atualizaModal'));
		}
		
		[Bindable(event="atualizaModal")]
		public function get modal():Boolean{
			return this._modal;
		}
		
		public function MenuPrincipal(modal:Boolean=false) {
			this.addEventListener(Event.ADDED_TO_STAGE, adicionado);
		}
		
		public function adicionado(event:Event):void{
			
			for(var i:int; i<numChildren; i++){
				if(getChildAt(i) is SimpleButton){
					SimpleButton(getChildAt(i)).addEventListener(MouseEvent.CLICK, itemSelecionado);
				}
			}
			
			this.modal = this.modalMc.visible = modal;
		}
		
		public function itemSelecionado(event:MouseEvent):void{
			dispatchEvent(new MenuItemSelecionadoEvent(MenuItemSelecionadoEvent.MENU_SELECTED_ITEM, String(event.target.name).replace('Btn', '')));
			stage.removeChild(this);
		}
	}
	
}
