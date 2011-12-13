/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is nexuslib.
 *
 * The Initial Developer of the Original Code is
 * Malachi Griffie <malachi@nexussays.com>.
 * Portions created by the Initial Developer are Copyright (C) 2011
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** */
package nexus.utils
{

import nexus.errors.NotImplementedError;
import nexus.utils.reflection.*;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	10/25/2011 3:26 AM
 */
public class ObjectUtils
{
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	/**
	 * Creates a new instance of the given type from the native object provided. Any values that exist in the provided
	 * object but not in the instance are ignored/dropped; and any values that exist in the instance but not the provided object
	 * are never assigned and left at their default values.
	 * Requires that the instance being instantiated provides a constructor with no arguments.
	 * @param	source	A native object which contains the values to assign into the newly created instance.
	 * @param	type	The class type of the object to instantiate
	 * @return	A newly instantiated typed object with fields assigned from the provided data object.
	 */
	static public function createTypedObjectFromNativeObject(type:Class, source:Object):Object
	{
		var result:Object;
		
		//TODO: consider adding error checking if the data and desired type do not match
		if(source == null)
		{
			result = null;
		}
		else if(Reflection.isPrimitive(type))
		{
			result = source;
		}
		else if(type == Date)
		{
			result = new Date(source);
		}
		else if(Reflection.isArray(type) || Reflection.isAssociativeArray(type))
		{
			result = new type();
			assignTypedObjectFromNativeObject(result, source);
		}
		else
		{
			try
			{
				//TODO: Handle constuctors with arguments?
				result = new type();
			}
			catch(e:Error)
			{
				//probably because ctor requires arguments
			}
			
			if(result != null)
			{
				assignTypedObjectFromNativeObject(result, source);
			}
		}
		return result;
	}
	
	/**
	 * Assigns properties and fields of the provided instance object from values in the provided data object. This method does not
	 * instantiate a new instance of the typed object, otherwise it is functionally equivalent to createTypedObjectFromNativeObject()
	 * @param	instance	A typed object instance whose members we want to assign from the provided data
	 * @param	source	A native object which contains the values to assign into the newly created instance.
	 */
	static public function assignTypedObjectFromNativeObject(instance:Object, source:Object):void
	{
		//assigning primitives is pointless without pass by ref
		if(source == null || Reflection.isPrimitive(instance) || instance == Date)
		{
			return;
		}
		else if(Reflection.isArray(instance))
		{
			//clear out the existing array if there is anything in it
			if(instance != null && instance.length > 0)
			{
				instance.splice(0, instance.length);
			}
			
			for(var x:int = 0; x < source.length; ++x)
			{
				if(x in source && source[x] !== undefined)
				{
					instance[x] = createTypedObjectFromNativeObject(Reflection.getVectorClass(instance), source[x]);
				}
			}
		}
		else if(Reflection.isAssociativeArray(instance))
		{
			//TODO: Need to clear out existing values, re-instantiate?
			for(var key:String in source)
			{
				instance[key] = createTypedObjectFromNativeObject(Reflection.getClass(source[key]), source[key]);
			}
		}
		else
		{
			var typeInfo:TypeInfo = Reflection.getTypeInfo(instance);
			for each(var member:AbstractMemberInfo in typeInfo.allMembers)
			{
				if(member is AbstractFieldInfo && !member.isStatic)
				{
					//only assign the field if it exists in the source data
					if(source != null && source[member.name] !== undefined)
					{
						if(AbstractFieldInfo(member).canWrite)
						{
							try
							{
								instance[member.name] = createTypedObjectFromNativeObject(AbstractFieldInfo(member).type, source[member.name]);
							}
							catch(e:Error)
							{
								//TODO: is a catch-all here ok?
							}
						}
						else
						{
							assignTypedObjectFromNativeObject(instance[member.name], source[member.name]);
						}
					}
				}
			}
		}
	}
	
	/**
	 * Reflects through the two objects provided and determines if objectA shares the same signature as objectB.
	 * @example	<pre>
	 * var objectA : Object = {
	 * 	"name": "Object A",
	 * 	"value": 50,
	 * 	"good": true
	 * };
	 *
	 * var objectB : Object = {
	 * 	"name": "Object B"
	 * };
	 *
	 * ObjectUtils.objectIsLike(objectA, objectB) ==> true
	 * ObjectUtils.objectIsLike(objectB, objectA) ==> false
	 * </pre>
	 * <pre>
	 * var objectA : Object = {
	 * 	"name": "Object A",
	 * 	"value": 50,
	 * 	"good": true
	 * };
	 *
	 * public interface IFoo
	 * {
	 * 	function get name():String;
	 * 	function get value():int;
	 * }
	 *
	 * ObjectUtils.objectIsLike(objectA, IFoo) ==> true
	 * </pre>
	 * @param	objectA
	 * @param	objectB
	 * @return
	 */
	static public function objectIsLike(instance:Object, instanceOrClassOrInterface:Object):Boolean
	{
		throw new NotImplementedError();
	}

	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
}

}