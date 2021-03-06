/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.core.webinitialization;

import diamond.core.apptype;

static if (isWebApi)
{
  /**
  * Generates the controller data.
  * Returns:
  *   An array with the names of the controllers to handle.
  */
  string[] generateControllerData()
  {
    import std.array : replace, split, array;
    import std.string : strip;
    import std.algorithm : filter;

    return import("controllers.config")
      .replace("\r", "").split("\n").filter!(c => c && c.strip().length).array;
  }
}
else
{
  /// Mixin template to load view data (name + content)
  mixin template LoadViewData(bool namesOnly = false)
  {
    /// Generates the functon "getViewData()" which gives you an AA like content[viewName]
    private string generateViewData()
    {
      import std.string : strip;
      import std.array : split, replace;

      enum viewConfig = import("views.config");

      string viewDataString = "string[string] getViewData()
      {
        string[string] viewData;
      ";

      foreach (line; viewConfig.split("\n"))
      {
        if (!line)
        {
          continue;
        }

        line = line.strip().replace("\r", "");

        if (!line && line.length)
        {
          continue;
        }

        auto data = line.split("|");

        if (data.length != 2)
        {
          continue;
        }

        static if (namesOnly)
        {
          auto viewName = data[0].strip();

          viewDataString ~= "  viewData[\"" ~ viewName ~ "\"] = \"" ~ viewName  ~ "\";";
        }
        else
        {
          viewDataString ~= "  viewData[\"" ~ data[0].strip() ~ "\"] = import(\"" ~ data[1].strip() ~ "\");";
        }
      }

      viewDataString ~= "  return viewData;
      }";

      return viewDataString;
    }

    mixin(generateViewData);
  }
}
