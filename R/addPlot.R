# Method Docx.addPlot 
# 
# Author: David GOHEL <david.gohel@lysis-consultants.fr>
# Date: 1 avr. 2013
# Version: 0.1
# July 9, 2013; added other arguments to grDevices:png call -cch
###############################################################################

setMethod("addPlot", "Docx", function(doc, fun
		, legend, stylename = "PlotReference"
		, width = 7, height = 6
		, pointsize = 12
                , units = "in"
                , bg = "white"
                , res = 72
                , family = ""
                , type = c("windows", "cairo", "cairo-png")
		
		, visible = T, ... ) {
			if( !missing( legend) && legend != "" ){
				# check style does exist
				if( !is.element( stylename , styles( doc ) ) )
					stop(paste("Style {", stylename, "} does not exists. Use styles() to list available styles.", sep = "") )
			}
			plotargs = list(...)

			dirname = tempfile( )
			dir.create( dirname )
			filename = paste( dirname, "/plot%03d.png" ,sep = "" )

			grDevices::png (filename = filename
					, width = width, height = height
					, pointsize = pointsize
					, units = units
                                        , bg = bg
                                        , res = res
                                        , family = family
                                        , type = type
                                        #antialias is not included b/c it can be specified by changing windows.options()$bitmap.aa.win
                                        #restoreConsole is not included b/c it isn't relevant in this context
			)
			
			fun(...)
			dev.off()

			plotfiles = list.files( dirname , full.names = T )
			
			
			for( i in plotfiles )
			# Send the graph to java that will 'encode64' and place it in a docx4J object
				.jcall( doc@obj, "V", "addImage", i )

			# Finally, add the legend of the Graph after the Drawing
			if( !missing( legend) && legend != "" ) addParagraph( doc, value = legend, stylename = stylename )
			doc
		})

