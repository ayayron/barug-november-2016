#'@exportHello World

sqlWorkbenchAddin <- function() {
  library(shiny)
  library(miniUI)
  
  ui <- miniPage(
    gadgetTitleBar("SQL Workbench"),
    miniTabstripPanel(
      miniTabPanel("Connect", icon = icon("database"),
          miniContentPanel(
            fileInput("load_file", "Load File")
          )
      )
    )
  )
  
  server <- function(input, output, session) {
    
    # read the file when it is uploaded
    return_df = eventReactive(input$load_file,{
      df = readRDS(input$load_file$datapath)
      return(df)
    })
    
    # when "Done" is clicked return the text
    observeEvent(input$done, {
      stopApp(return_df())
    })
  }

  # create a dialog window instead of having it return in the viewer pane
  viewer <- dialogViewer("sqlWorkbench", width = 800, height = 800) 
  
  runGadget(ui, server, viewer = viewer)
}