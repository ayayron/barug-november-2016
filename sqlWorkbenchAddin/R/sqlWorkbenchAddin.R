#'@exportHello World

sqlWorkbenchAddin <- function() {
  library(shiny)
  library(miniUI)
  
  ui <- miniPage(
    gadgetTitleBar("SQL Workbench")
  )
  
  server <- function(input, output, session) {
    
    # when "Done" is clicked return the text
    observeEvent(input$done, {
      stopApp(rstudioapi::insertText("Hello World"))
    })
  }

  # create a dialog window instead of having it return in the viewer pane
  viewer <- dialogViewer("sqlWorkbench", width = 800, height = 800) 
  
  runGadget(ui, server, viewer = viewer)
}