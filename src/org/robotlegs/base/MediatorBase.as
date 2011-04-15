/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.base
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.getDefinitionByName;
	
	import org.robotlegs.core.IMediator;
	
	/**
	 * An abstract <code>IMediator</code> implementation
	 */
	public class MediatorBase implements IMediator
	{
		/**
		 * Flex framework work-around part #1
		 */
		protected static var UIComponentClass:Class;
		
		/**
		 * Mobile framework work-around part #1
		 */
		protected static var ViewClass:Class
		
		/**
		 * Flex framework work-around part #2
		 */
		protected static const flexAvailable:Boolean = checkFlex();

		/**
		 * Flex framework work-around part #2
		 */
		protected static const mobileAvailable:Boolean = checkMobile();
		
		/**
		 * Internal
		 *
		 * <p>This Mediator's View Component - used by the RobotLegs MVCS framework internally.
		 * You should declare a dependency on a concrete view component in your
		 * implementation instead of working with this property</p>
		 */
		protected var viewComponent:Object;
		
		/**
		 * Internal
		 *
		 * <p>In the case of deffered instantiation, onRemove might get called before
		 * onCreationComplete has fired. This here Bool helps us track that scenario.</p>
		 */
		protected var removed:Boolean;
		
		//---------------------------------------------------------------------
		//  Constructor
		//---------------------------------------------------------------------
		
		/**
		 * Creates a new <code>Mediator</code> object
		 */
		public function MediatorBase()
		{
		}
		
		//---------------------------------------------------------------------
		//  API
		//---------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function preRegister():void
		{
			removed = false;
			
			if (flexAvailable && (viewComponent is UIComponentClass))
			{
				if (mobileAvailable && (viewComponent is ViewClass))	//mediating a mobile View
				{
					if (!viewComponent['isActive'])
					{
						IEventDispatcher(viewComponent).addEventListener('viewActivate', _onViewActivate);
					} else
					{
						IEventDispatcher(viewComponent).addEventListener('viewDeactivate', _onViewDeactivate);
					}
					IEventDispatcher(viewComponent).addEventListener('deactivate', _onDeactivate);
					IEventDispatcher(viewComponent).addEventListener('removing', _onRemoving);
				}
				else if (!viewComponent['initialized'])
				{
					IEventDispatcher(viewComponent).addEventListener('creationComplete', onCreationComplete, false, 0, true);
				}				
				//if the mobile view is active or the component is initialized 
				if (viewComponent['initialized'] || viewComponent['isActive'])
				{
					onRegister();	
				}
				
			}
			else
			{
				onRegister();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function onRegister():void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function preRemove():void
		{
			removed = true;
			onRemove();
		}
		
		/**
		 * @inheritDoc
		 */
		public function onRemove():void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function getViewComponent():Object
		{
			return viewComponent;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setViewComponent(viewComponent:Object):void
		{
			this.viewComponent = viewComponent;
		}
		
		//---------------------------------------------------------------------
		//  Internal
		//---------------------------------------------------------------------
		
		/**
		 * Flex framework work-around part #3
		 *
		 * <p>Checks for availability of the Flex framework by trying to get the class for UIComponent.</p>
		 */
		protected static function checkFlex():Boolean
		{
			try
			{
				UIComponentClass = getDefinitionByName('mx.core::UIComponent') as Class;
			}
			catch (error:Error)
			{
				// do nothing
			}
			return UIComponentClass != null;
		}
		
		/**
		 * Mobile framework work-around part #3
		 *
		 * <p>Checks for availability of the Mobile framework by trying to get the class for View.</p>
		 */
		protected static function checkMobile():Boolean
		{
			try
			{
				ViewClass = getDefinitionByName('spark.components::View') as Class;
			}
			catch (error:Error)
			{
				// do nothing
			}
			return ViewClass != null;
		}
		
		/**
		 * Flex framework work-around part #4
		 *
		 * <p><code>FlexEvent.CREATION_COMPLETE</code> handler for this Mediator's View Component</p>
		 *
		 * @param e The Flex <code>FlexEvent</code> event
		 */
		protected function onCreationComplete(e:Event):void
		{
			IEventDispatcher(e.target).removeEventListener('creationComplete', onCreationComplete);
			
			if (!removed)
				onRegister();
		}
		
		/**
		 * Mobile framework work-around part #4
		 *
 		 * <p><code>Event.ACTIVATE</code> handler for this Mediator's View Component</p>
		 *
		 * @param event The Flex <code>Event</code> event
		 */
		private function _onActivate(event:Event):void
		{
			IEventDispatcher(event.target).removeEventListener('activate', _onActivate, false);
			IEventDispatcher(event.target).addEventListener('viewDeactivate', _onViewDeactivate);
			IEventDispatcher(event.target).addEventListener('deactivate', _onDeactivate);
			
			removed = false;

			onRegister();
		}
		
		/**
		 * Mobile framework work-around part #5
		 *
 		 * <p><code>Event.DEACTIVATE</code> handler for this Mediator's View Component</p>
		 *
		 * @param event The Flex <code>Event</code> event
		 */
		private function _onDeactivate(event:Event):void
		{
			IEventDispatcher(event.target).removeEventListener('deactivate', _onDeactivate);
			IEventDispatcher(event.target).addEventListener('activate', _onActivate);
		}
		
		/**
		 * Mobile framework work-around part #6
		 *
 		 * <p><code>ViewNavigatorEvent.VIEW_ACTIVATE</code> handler for this Mediator's View Component</p>
		 *
		 * @param event The Flex <code>ViewNavigatorEvent</code> event
		 */
		private function _onViewActivate(event:Event):void
		{
			IEventDispatcher(event.target).removeEventListener('viewActivate', _onViewActivate);

			if (!removed)
				onRegister();
		}
		
		/**
		 * Mobile framework work-around part #7
		 *
  		 * <p><code>ViewNavigatorEvent.VIEW_DEACTIVATE</code> handler for this Mediator's View Component</p>
		 *
		 * @param event The Flex <code>ViewNavigatorEvent</code> event
		 */
		private function _onViewDeactivate(event:Event):void
		{
			IEventDispatcher(event.target).removeEventListener('viewDeactivate', _onViewDeactivate);

			preRemove();
		}
		
		/**
		 * Mobile framework work-around part #8
		 *
 		 * <p><code>ViewNavigatorEvent.REMOVING</code> handler for this Mediator's View Component</p>
		 *
		 * @param event The Flex <code>ViewNavigatorEvent</code> event
		 */
		private function _onRemoving(event:Event):void
		{
			IEventDispatcher(event.target).removeEventListener('activate', _onActivate);
			IEventDispatcher(event.target).removeEventListener('deactivate', _onDeactivate);
			IEventDispatcher(event.target).removeEventListener('viewActivate', _onViewActivate);
			IEventDispatcher(event.target).removeEventListener('viewDeactivate', _onViewDeactivate);
			IEventDispatcher(event.target).removeEventListener('removing', _onRemoving);
		}
	
	}
}
