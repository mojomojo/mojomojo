/*
 *
 * Copyright (c) 2006-2008 Sam Collett (http://www.texotela.co.uk)
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 * 
 * Version 2.0.1
 * Demo: http://www.texotela.co.uk/code/jquery/checkboxes/
 *
 * $LastChangedDate: 2008-02-12 17:34:52 +0000 (Tue, 12 Feb 2008) $
 * $Rev: 4734 $
 */

 
/*
 * Toggle all checkboxes contained within a form
 *
 * @name     toggleCheckboxes
 * @param    filter   only toggle checkboxes matching this expression
 * @param    returnChecked   return checkboxes as jQuery object, default false
 * @author   Sam Collett (http://www.texotela.co.uk)
 * @example  $("#myform").toggleCheckboxes();
 * @example  $("#myform").toggleCheckboxes(".onlyme");
 * @example  $("#myform").toggleCheckboxes(":not(.notme)");
 * @example  $("#myform").toggleCheckboxes("*", true);
 *
 */
jQuery.fn.toggleCheckboxes = function(filter, returnChecked)
{
	filter = filter || "*";
	returnChecked = returnChecked || false;
	var returnWhat = jQuery([]);
	this.each(
		function()
		{
			var checked = jQuery("input[@type=checkbox]", this).filter(filter).each(
				function()
				{
					this.checked = !this.checked;
				}
			).filter(":checked");
			returnWhat = checked;
		}
	);
	if(!returnChecked)
	{
		returnWhat = this;
	}
	return returnWhat;
};

/*
 * Check all checkboxes contained within a form
 *
 * @name     checkCheckboxes
 * @param    filter   only check checkboxes matching this expression
 * @param    returnChecked   return checkboxes as jQuery object, default false
 * @author   Sam Collett (http://www.texotela.co.uk)
 * @example  $("#myform").checkCheckboxes();
 * @example  $("#myform").checkCheckboxes(".onlyme");
 * @example  $("#myform").checkCheckboxes(":not(.notme)");
 * @example  $("#myform").checkCheckboxes("*", true);
 *
 */
jQuery.fn.checkCheckboxes = function(filter, returnChecked)
{
	filter = filter || "*";
	returnChecked = returnChecked || false;
	var returnWhat = jQuery([]);
	this.each(
		function()
		{
			var checked = jQuery("input[@type=checkbox]", this).filter(filter).each(
				function()
				{
					this.checked = true;
				}
			).filter(":checked");
			returnWhat = checked;
		}
	);
	if(!returnChecked)
	{
		returnWhat = this;
	}
	return returnWhat;
};

/*
 * UnCheck all checkboxes contained within a form
 *
 * @name     unCheckCheckboxes
 * @param    filter   only check checkboxes matching this expression
 * @param    returnUnChecked   return unchecked checkboxes as jQuery object, default false
 * @author   Sam Collett (http://www.texotela.co.uk)
 * @example  $("#myform").unCheckCheckboxes();
 * @example  $("#myform").unCheckCheckboxes(".onlyme");
 * @example  $("#myform").unCheckCheckboxes(":not(.notme)");
 * @example  $("#myform").unCheckCheckboxes("*", true);
 *
 */
jQuery.fn.unCheckCheckboxes = function(filter, returnUnChecked)
{
	filter = filter || "*";
	returnUnChecked = returnUnChecked || false;
	var returnWhat = jQuery([]);
	this.each(
		function()
		{
			var unChecked = jQuery("input[@type=checkbox]", this).filter(filter).each(
				function()
				{
					this.checked = false;
				}
			).filter(":not(:checked)");
			returnWhat = unChecked;
		}
	);
	if(!returnUnChecked)
	{
		returnWhat = this;
	}
	return returnWhat;
};

/*
 * Makes checkboxes behave like a radio button group
 *   i.e. only one can be selected at a time
 *
 * @name     radioCheckboxGroup
 * @param    name  field name (leave blank to apply to all check boxes)
 * @param    filter  apply to checkboxes matching this expression
 * @author   Sam Collett (http://www.texotela.co.uk)
 * @example  $.radioCheckboxGroup("fieldname");
 * @example  $.radioCheckboxGroup("fieldname", ".myclass");
 * @example  $.radioCheckboxGroup("", ".myclass");
 *
 */
jQuery.radioCheckboxGroup = function(name, filter)
{
	filter = filter || "*";
	var expression = "input[@type=checkbox]";
	if(name)
	{
		expression += "[@name=" + name + "]"
	}
	var x = jQuery(expression).filter(filter);
	x.click(
		function()
		{
			// uncheck every other box with the same name
			x.not(this).each(
				function()
				{
					this.checked = false;
				}
			).end();
		}
	);
};