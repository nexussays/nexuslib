﻿// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus
{

import avmplus.AVMDescribeType;

import flash.errors.IllegalOperationError;
import flash.utils.*;

import nexus.utils.reflection.Reflection;


/**
 * Base class for enumerations. Used extensively throughout the system.
 * @example   <listing version="3.0">
public class MyEnum extends Enum
{
   //This provides additional assurance that your Enum will be properly created. However, if
   //you use proper syntax, it is not required.
   {Enum.initialize(MyEnum)}

   public static const Enum1 : MyEnum = new MyEnum();
   public static const Enum2 : MyEnum = new MyEnum();
}
 * </listing>
 */
public class Enum implements IEnum
{
   /**
    * Holds an EnumSet of all the values of each Enum
    */
   private static const s_enumRegistry : Dictionary = new Dictionary();
   
   /**
    * Internal method used to register a class in the registry and initialize all instance values
    */
   protected static function initialize(enumType : Class) : void
    {
      if(s_enumRegistry[enumType] == null)
      {
         var typeArray : Array = new Array();
         var typeInfo : Object = AVMDescribeType.getJson(enumType);
         var flag : uint = 1;
         typeInfo.variables.sortOn("name");
         for(var x : int = 0; x < typeInfo.variables.length; ++x)
         {
            var fieldInfo : Object = typeInfo.variables[x];
            //account for namespaces
            var enum : Enum = enumType[new QName(fieldInfo.uri == null ? "" : new Namespace("", fieldInfo.uri), fieldInfo.name)] as Enum;
            if(enum != null)
            {
               if(fieldInfo.access == "readwrite")
               {
                  throw new SyntaxError("All Enum values must be defined as constants");
               }
               enum.m_name = fieldInfo.name;
               enum.m_fullname = Reflection.getQualifiedClassName(enum) + "." + fieldInfo.name;
               if(enum.m_value == int.MIN_VALUE)
               {
                  enum.m_value = flag;
               }
               enum.m_isInitialized = true;
               
               flag <<= 1;
               
               typeArray.push(enum);
            }
         }
         
         s_enumRegistry[enumType] = EnumSet.fromArrayInternal(typeArray);
      }
    }
   
   //--------------------------------------
   //   INSTANCE VARIABLES
   //--------------------------------------
   
   /**
    * @private
    */
   protected var m_value : int;
   
   private var m_name : String;
   private var m_fullname : String;
   
   /**
    * Internal field used by the Enum initializer
    */
   private var m_isInitialized : Boolean;
   
   //--------------------------------------
   //   CONSTRUCTOR
   //--------------------------------------
   
   public function Enum(valueOverride: Number = NaN)
   {
      m_value = (!isNaN(valueOverride) && isFinite(valueOverride)) ? valueOverride : int.MIN_VALUE;
      
      //Class will not be available for Reflection until it has finished instantiating all its constants, so if we are
      //able to get the class, then it has already been fully initialized and therefore this constructor was called
      //from outside the class definition
      if(getDefinitionByName(getQualifiedClassName(this)) != null)
      {
         throw new IllegalOperationError("Cannot create an instance of Enum " + this["constructor"]);
      }
   }
   
   //--------------------------------------
   //   GETTER/SETTERS
   //--------------------------------------
   
   /**
    * The name of this enum item
    */
   public function get name():String
   {
      confirmInit();
      
      return m_name;
   }
   
   /**
    * The class and name of this enum item
    */
   public final function get fullname():String
   {
      confirmInit();
      
      return m_fullname;
   }
   
   /**
    * The integer value of this enum item. Unless overridden in your enum subclass ctor, this
    * can be used as a flag to perform bitwise operations.
    */
   public function get value():int
   {
      confirmInit();
      
      return m_value;
   }
   
   //--------------------------------------
   //   PUBLIC INSTANCE METHODS
   //--------------------------------------
   
   /**
    * @inheritDoc
    */
   public final function equals(matchValue:Object):Boolean
   {
      confirmInit();
      
      if(matchValue == null)
      {
         return false;
      }
      else if(matchValue is Enum)
      {
         return this == matchValue;
      }
      else if(matchValue is EnumSet)
      {
         return EnumSet(matchValue).equals(this);
      }
      else if(matchValue is Array || matchValue is Vector.<*>)
      {
         return matchValue.length == 1 && matchValue[0] == this;
      }
      return false;
   }
   
   /**
    * @inheritDoc
    */
   public final function intersects(matchValue:Object):Boolean
   {
      confirmInit();
      
      if(matchValue == null)
      {
         return false;
      }
      else if(matchValue is Enum)
      {
         return this == matchValue;
      }
      else if(matchValue is EnumSet)
      {
         return EnumSet(matchValue).intersects(this);
      }
      else if(matchValue is Array || matchValue is Vector.<*>)
      {
         for each(var val : * in matchValue)
         {
            if(val == this)
            {
               return true;
            }
         }
         return false;
      }
      return false;
   }
   
   public function toString():String
   {
      return this.name;
   }
   
   //--------------------------------------
   //   PUBLIC CLASS METHODS
   //--------------------------------------
   
   /**
    * Retrieve all the values of the provided enum class
    * @param   enumType   The class to retrieve values from
    * @return   An EnumSet containing all the values of the provided enum
    */
   public static function values(enumType:Class):EnumSet
   {
      initialize(enumType);
      
      return s_enumRegistry[enumType];
   }
   
   /**
    * Given an enum type, return the enum matching the provided value. If none exists, reutrn null.
    * @param   enumType
    * @param   value   A value, most likely a string, to parse to an enum
    * @param   isCaseSensitive   If true, matching is not case sensitive
    * @return   An enum of the provided type matching the provided value, or null if none exists.
    */
   public static function fromString(enumType:Class, value:Object, isCaseSensitive:Boolean=false):Enum
    {
      initialize(enumType);
      
      var str : String = isCaseSensitive ? (value + "") : (value + "").toLowerCase();
      var values : Array = s_enumRegistry[enumType].values;
        for(var x : int = 0; x < values.length; ++x)
        {
         var enum : Enum = values[x];
         if((isCaseSensitive && enum.m_name == str) || (!isCaseSensitive && enum.m_name.toLowerCase() == str))
         {
            return enum;
         }
        }
      
      return null;
    }
   
   //--------------------------------------
   //   PRIVATE METHODS
   //--------------------------------------
   
   private function confirmInit():void
   {
      if(!m_isInitialized)
      {
         initialize(Reflection.getClass(this));
      }
   }
}
}
