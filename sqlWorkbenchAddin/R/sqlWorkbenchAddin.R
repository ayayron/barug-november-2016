#'@export

sqlWorkbenchAddin <- function() {
  library(shiny)
  library(miniUI)
  library(ggplot2)
  
  # get verbose output from shiny for debugging
  options(shiny.trace = TRUE)

  # path to the installed www folder
  addin_resources = system.file("www", package = "sqlWorkbenchAddin")

  ui <- miniPage(
    tags$head(includeCSS(file.path(addin_resources, "workbench.css"))),
    gadgetTitleBar("SQL Workbench"),
    miniTabstripPanel(
      miniTabPanel("Connect", icon = icon("database"),
          miniContentPanel(fillPage(
            fillRow(fileInput("load_file", "Load File"), height="100px"),
            fillRow(textInput("sql_host", "Hostname", "127.0.0.1"),
            textInput("sql_user", "Username", "root"),
            textInput("sql_port", "Port", "3306"), height="100px"),
            fillRow(passwordInput("sql_pw", "Password"),
            actionButton("sql_conn_btn", "Connect", 
                         style = "background-color:red; color:white;"),
            textInput("sql_db", "Select SQL DB", "barug"),
            textInput("sql_table_input", "Select SQL Table", "iris"), height="100px")
          )
          )
      ),
      miniTabPanel("Table", icon = icon("table"),
            fillRow(textInput("table_filter", "Table Filter"), 
                    actionButton("filter_btn", "Filter!"), height = "75px"),
            fillRow(dataTableOutput("sql_table"), height = "300px")
      ),
      miniTabPanel("Chart", icon = icon("line-chart"),
                   fillPage(fillRow(
                     fillCol(selectInput("x_select", "Select X Value", choices = c("None")),
                             selectInput("y_select", "Select Y Value", choices = c("None")),
                             selectInput("plot_type","Plot Type", choices = c("line"="geom_line()",
                                                                              "point"="geom_point()"))),
                     plotOutput("sql_plot"), flex = c(1,4)
                   ))
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
      df$table = tryCatch({
                    subset(df$table, eval(parse(text = input$table_filter)))
                  }, error = function(e) {
                        df$table      
                  })
    })
    
    observeEvent(input$sql_conn_btn, {
      # connect to the SQL database
      
      library(RMySQL)
      
      if (input$sql_pw == "") {
        # no password can't pass empty string
        conn = dbConnect(MySQL(), host = input$sql_host, dbname = input$sql_db,
                         user = input$sql_user, port = as.integer(input$sql_port))
      } else {
        conn = dbConnect(MySQL(), host = input$sql_host, dbname = "barug",
                         user = input$sql_user, port = as.integer(input$sql_port),
                         password = input$sql_pw)
      }

      # query table and return response to reactive table
      response = dbSendQuery(conn, paste("select * from ", input$sql_table_input))
      df$table = dbFetch(response)
    })
    
    # Output a DataTable (js package, not data.table R package)
    # set options https://datatables.net/reference/option/
    output$sql_table = renderDataTable(
      df$table,
      options = list(pageLength = 5, scrollY = 300)
    )
    
    # update filters for plot
    observe({
        updateSelectInput(session, "x_select", choices = names(df$table))
        updateSelectInput(session, "y_select", choices = names(df$table))
    })
    
    output$sql_plot = renderPlot({
      
      # eval used to parse select input text as columns of data frame
      p = ggplot(df$table, aes(x = eval(parse(text = input$x_select)),
                              y = eval(parse(text = input$y_select)))) + 
                ylab(input$y_select) + xlab(input$x_select)
      
      # based on select input set the type of plot
      # the whole renderPlot() is re-evaluated every time the input changes
      if (input$plot_type == "geom_line()") {
        p = p + geom_line()
      }
      if (input$plot_type == "geom_point()") {
        p = p + geom_point()
      }
      p
    })
    
    # when "Done" is clicked return the text
    observeEvent(input$done, {
      
      # Disconnect database if there is a connection
      db_conns = dbListConnections(MySQL())
      for (con in db_conns) {
        dbDisconnect(con)
      }
      
      # add the table to Rstudio workspace global environment
      .GlobalEnv$mydf = df$table
      
      # return table to console. Save by setting mydf = .Last.value
      stopApp(df$table)
    })
  }

  # create a dialog window instead of having it return in the viewer pane
  viewer <- dialogViewer("sqlWorkbench", width = 800, height = 800) 
  
  runGadget(ui, server, viewer = viewer)
}