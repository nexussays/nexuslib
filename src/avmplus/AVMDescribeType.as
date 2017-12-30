// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package avmplus
{

/**
 * Provides access to the avmplus.describeTypeJSON method which was (accidentally?) exposed in Flash 10.1
 *
 * @see   http://hg.mozilla.org/tamarin-redux/file/tip/core/DescribeType.as
 * @private
 */
public final class AVMDescribeType
{
   //--------------------------------------
   //   CLASS CONSTANTS
   //--------------------------------------
   
   private static var s_isAvailable : Boolean = false;
   
   //as defined in avm
   /*
   public const HIDE_NSURI_METHODS:uint    = 0x0001;
    public const INCLUDE_BASES:uint         = 0x0002;
    public const INCLUDE_INTERFACES:uint    = 0x0004;
    public const INCLUDE_VARIABLES:uint     = 0x0008;
    public const INCLUDE_ACCESSORS:uint     = 0x0010;
    public const INCLUDE_METHODS:uint       = 0x0020;
    public const INCLUDE_METADATA:uint      = 0x0040;
    public const INCLUDE_CONSTRUCTOR:uint   = 0x0080;
    public const INCLUDE_TRAITS:uint        = 0x0100;
    public const USE_ITRAITS:uint           = 0x0200;
    // if set, hide everything from the base Object class
    public const HIDE_OBJECT:uint           = 0x0400;
   //*/
   private static const INCLUDE_BASES:uint      =   avmplus.INCLUDE_BASES;
   private static const INCLUDE_INTERFACES:uint=   avmplus.INCLUDE_INTERFACES;
   private static const INCLUDE_VARIABLES:uint   =   avmplus.INCLUDE_VARIABLES;
   private static const INCLUDE_ACCESSORS:uint   =   avmplus.INCLUDE_ACCESSORS;
   private static const INCLUDE_METHODS:uint   =   avmplus.INCLUDE_METHODS;
   private static const INCLUDE_METADATA:uint   =   avmplus.INCLUDE_METADATA;
   private static const INCLUDE_CONSTRUCTOR:uint   =   avmplus.INCLUDE_CONSTRUCTOR;
   private static const INCLUDE_TRAITS:uint   =   avmplus.INCLUDE_TRAITS;
   private static const USE_ITRAITS:uint      =   avmplus.USE_ITRAITS;
   private static const HIDE_OBJECT:uint      =   avmplus.HIDE_OBJECT;
   
   private static const GET_CLASS : uint    =                                      INCLUDE_VARIABLES | INCLUDE_ACCESSORS | INCLUDE_METHODS | INCLUDE_METADATA |                       INCLUDE_TRAITS |               HIDE_OBJECT;
   private static const GET_INSTANCE : uint = INCLUDE_BASES | INCLUDE_INTERFACES | INCLUDE_VARIABLES | INCLUDE_ACCESSORS | INCLUDE_METHODS | INCLUDE_METADATA | INCLUDE_CONSTRUCTOR | INCLUDE_TRAITS | USE_ITRAITS | HIDE_OBJECT;
   
   //--------------------------------------
   //   STATIC INITIALIZER
   //--------------------------------------
   
   {
      try
      {
         if(describeTypeJSON is Function && describeType is Function)
         {
            s_isAvailable = true;
         }
      }
      catch(e:Error)
      {
         s_isAvailable = false;
      }
   }
   
   //--------------------------------------
   //   GETTERS/SETTERS
   //--------------------------------------
   
   public static function get isAvailable():Boolean { return s_isAvailable; }
   
   //--------------------------------------
   //   PUBLIC CLASS METHODS
   //--------------------------------------
   
   public static function getJson(object:Object):Object
   {
      var factory : Object = describeTypeJSON(object, GET_INSTANCE);
      factory.traits.isDynamic = factory.isDynamic;
      factory.traits.isFinal = factory.isFinal;
      factory.traits.isStatic = factory.isStatic;
      factory.traits.name = factory.name;
      factory = factory.traits;
      factory.methods = factory.methods || [];
      factory.accessors = factory.accessors || [];
      factory.variables = factory.variables || [];
      factory.constructor = factory.constructor || [];
      
      var obj : Object = describeTypeJSON(object, GET_CLASS);
      obj = obj.traits;
      obj.methods = obj.methods || [];
      obj.accessors = obj.accessors || [];
      obj.variables = obj.variables || [];
      delete obj.bases;
      delete obj.constructor;
      delete obj.interfaces;
      
      obj.factory = factory;
      
      return obj;
   }
   
   /**
    * This method just calls getJson() and parses the result to XML. It is advised to not use this method unless you are sending the data
    * to something that expects it in the standard flash.utils.describeType() format.
    * @param   object
    * @return
    */
   public static function getXml(object:Object):XML
   {
      return describeType(object, GET_CLASS);
   }
}

}
