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
      ),
      miniTabPanel("Table", icon = icon("table"),
            fillRow(textInput("table_filter", "Table Filter"), 
                    actionButton("filter_btn", "Filter!"), height = "75px"),
            fillRow(dataTableOutput("sql_table"), height = "300px")
      )
    )
  )
  
  server <- function(input, output, session) {
    
    # create our reactive data frame to be used later
    df = reactiveValues(table = NULL)
    
    # read the file when it is uploaded
    observeEvent(input$load_file,{
      df$table = readRDS(input$load_file$datapath)
    })
    
    observeEvent(input$filter_btn,{
      df$table = subset(df$table, eval(parse(text = input$table_filter)))
    })
    
    # Output a DataTable (js package, not data.table R package)
    # set options https://datatables.net/reference/option/
    output$sql_table = renderDataTable(
      df$table,
      options = list(pageLength = 5, scrollY = 300)
    )
    
    # when "Done" is clicked return the text
    observeEvent(input$done, {
      stopApp(df$table)
    })
  }

  # create a dialog window instead of having it return in the viewer pane
  viewer <- dialogViewer("sqlWorkbench", width = 800, height = 800) 
  
  runGadget(ui, server, viewer = viewer)
}