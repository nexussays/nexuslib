// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils
{

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;
import nexus.errors.NotImplementedError;
import nexus.utils.reflection.*;

/**
 * ...
 *
 */
public class ObjectUtils
{
   //--------------------------------------
   //   PUBLIC CLASS METHODS
   //--------------------------------------
   
   /**
    * Creates a new instance of the given type from the native object provided. Any values that exist in the provided
    * object but not in the instance are ignored/dropped; and any values that exist in the instance but not the provided object
    * are never assigned and left at their default values.
    * Requires that the instance being instantiated provides a constructor with no arguments.
    * @param   source   A native object which contains the values to assign into the newly created instance.
    * @param   type   The class type of the object to instantiate
    * @return   A newly instantiated typed object with fields assigned from the provided data object.
    */
   static public function createTypedObjectFromNativeObject(type:Class, source:Object, applicationDomain:ApplicationDomain=null):Object
   {
      var result:Object;
      
      //TODO: consider adding error checking if the data and desired type do not match
      
      //doesn't matter what the desired type is if the source data is null
      if(source == null)
      {
         result = null;
      }
      else if(type == Date)
      {
         result = new Date(source);
      }
      else if(Reflection.isScalar(type) || type == null)
      {
         //if the object we are trying to create is a scalar but the source is not, try to cast the source to the desired type
         result = Reflection.isScalar(source) ? source : source as type;
      }
      else if(Reflection.isArrayType(type) || Reflection.isAssociativeArray(type))
      {
         //assume we can just instantiate native types directly without going through an app domain
         result = new type();
         assignTypedObjectFromNativeObject(result, source, applicationDomain);
      }
      else
      {
         //see if there is a fromNative(object):Object method on this class, and call it if so
         var typeInfo : TypeInfo = Reflection.getTypeInfo(type, applicationDomain);
         var methodInfo : MethodInfo = typeInfo.getMethodByName("fromNative");
         if(   methodInfo != null && methodInfo.isStatic
            && methodInfo.returnType != null
            && methodInfo.parameters.length == 1
            && methodInfo.parameters[0].type == Object)
         {
            try
            {
               result = methodInfo.invoke(type, source);
            }
            catch(e:Error)
            {
               trace(e);
            }
         }
         else
         {
            try
            {
               //TODO: Handle constuctors with arguments?
               result = new (Reflection.getClass(type, applicationDomain))();
            }
            catch(e:Error)
            {
               //probably because ctor requires arguments, if we add support for that then this can catch more interesting errors
               trace(e);
            }
         }
         
         if(result != null)
         {
            assignTypedObjectFromNativeObject(result, source, applicationDomain);
         }
      }
      return result;
   }
   
   /**
    * Assigns properties and fields of the provided instance object from values in the provided data object. This method does not
    * instantiate a new instance of the typed object, otherwise it is functionally equivalent to createTypedObjectFromNativeObject()
    * @param   instance   A typed object instance whose members we want to assign from the provided data
    * @param   source   A native object which contains the values to assign into the newly created instance.
    */
   static public function assignTypedObjectFromNativeObject(instance:Object, source:Object, applicationDomain:ApplicationDomain=null):void
   {
      //assigning primitives is pointless without pass by ref
      if(source == null || instance == null || Reflection.isScalar(instance) || instance is Date)
      {
         return;
      }
      else if(Reflection.isArrayType(instance))
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
               instance[x] = createTypedObjectFromNativeObject(Reflection.getVectorType(instance, applicationDomain) || Reflection.getClass(source[x], applicationDomain), source[x], applicationDomain);
            }
         }
      }
      //if the object is an associative array, iterate over all the keys in the source and assign them
      else if(Reflection.isAssociativeArray(instance))
      {
         //TODO: Need to clear out existing values, re-instantiate?
         for(var key:String in source)
         {
            //TODO: Does it even make any sense to get the class of the source?
            instance[key] = createTypedObjectFromNativeObject(Reflection.getClass(source[key], applicationDomain), source[key], applicationDomain);
         }
      }
      else
      {
         var typeInfo:TypeInfo = Reflection.getTypeInfo(instance, applicationDomain);
         if(typeInfo.isDynamic)
         {
            var fieldsInDataFoundInClass : Object = { };
         }
         
         for each(var member:AbstractMemberInfo in typeInfo.allMembers)
         {
            var field : AbstractFieldInfo = member as AbstractFieldInfo;
            //only assign the field if it exists in the source data
            if(field != null && !field.isStatic)
            {
               var qname : QName = field.qname;
               var qnameString : String = qname.toString();
               if(qnameString in source)
               {
                  if(fieldsInDataFoundInClass != null)
                  {
                     fieldsInDataFoundInClass[qnameString] = true;
                  }
                  
                  if(field.canWrite)
                  {
                     try
                     {
                        instance[qname] = createTypedObjectFromNativeObject(field.type, source[qnameString], applicationDomain);
                     }
                     catch(e:Error)
                     {
                        //TODO: is a catch-all here ok?
                        trace(e);
                     }
                  }
                  else
                  {
                     assignTypedObjectFromNativeObject(instance[qname], source[qnameString], applicationDomain);
                  }
               }
            }
         }
         
         if(typeInfo.isDynamic)
         {
            for(var dynamicKey:String in source)
            {
               if(!(dynamicKey in fieldsInDataFoundInClass))
               {
                  //TODO: Does it even make any sense to get the class of the source?
                  instance[dynamicKey] = createTypedObjectFromNativeObject(Reflection.getClass(source[dynamicKey], applicationDomain), source[dynamicKey], applicationDomain);
               }
            }
            fieldsInDataFoundInClass = null;
         }
      }
   }
   
   /**
    * Reflects through the two objects provided and determines if objectA shares the same signature as objectB.
    * @example   <listing version="3.0">
    * var objectA : Object = {
    *    "name": "Object A",
    *    "value": 50,
    *    "good": true
    * };
    *
    * var objectB : Object = {
    *    "name": "Object B"
    * };
    *
    * ObjectUtils.objectIsLike(objectA, objectB) ==> true
    * ObjectUtils.objectIsLike(objectB, objectA) ==> false
    * </listing>
    * <listing version="3.0">
    * var objectA : Object = {
    *    "name": "Object A",
    *    "value": 50,
    *    "good": true
    * };
    *
    * public interface IFoo
    * {
    *    function get name():String;
    *    function get value():int;
    * }
    *
    * ObjectUtils.objectIsLike(objectA, IFoo) ==> true
    * </listing>
    * @param   objectA
    * @param   objectB
    * @return
    */
   static public function objectIsLike(instance:Object, instanceOrClassOrInterface:Object):Boolean
   {
      throw new NotImplementedError();
   }

   //--------------------------------------
   //   PRIVATE CLASS METHODS
   //--------------------------------------
}

}
