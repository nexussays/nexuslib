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
package nexus.utils.serialization.json
{
	import nexus.errors.NotImplementedError;
	import nexus.utils.serialization.ISerializer;

/**
 * ...
 * @author	Malachi Griffie
 * @since	9/29/2011 2:13 AM
 */
public class JsonSerializer implements ISerializer
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function JsonSerializer()
	{
		
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function serialize(sourceObject:Object, includeReadOnlyProperties:Boolean = false):Object
	{
		return JsonSerializer.serialize(sourceObject, includeReadOnlyProperties);
	}
	
	public function deserialize(serializedObject:Object, classType:Class = null):Object
	{
		return JsonSerializer.deserialize(serializedObject, classType);
	}
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	static public function serialize(sourceObject:Object, includeReadOnlyProperties:Boolean = false):Object
	{
		throw new NotImplementedError();
	}
	
	static public function deserialize(serializedObject:Object, classType:Class = null):Object
	{
		throw new NotImplementedError();
	}
}

}