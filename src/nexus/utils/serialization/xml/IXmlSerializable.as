// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils.serialization.xml
{
   
/**
 * Implement on objects that want to override their serialization to XML
 * 
 */
public interface IXmlSerializable
{
   function toXML():XML;
}

}
