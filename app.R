#Required Libraries

library(shiny)
library(leaflet)
library(dplyr)
library(leaflet.extras)


#Shiny bootstrap page user interface
ui <- bootstrapPage(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    leafletOutput("lmap", width = "100%", height = "100%"),
    #fixed panel with selections (range, class, and full name)
    absolutePanel(top = 10, right = 10,
                  titlePanel(h3("RSPCA Complaints")),
                  sliderInput("range", "Select Timespan", min(animal_complaints_rspca$year_quarter),
                              max(animal_complaints_rspca$year_quarter),
                              value = range(animal_complaints_rspca$year_quarter), step = 0.1),
                  
                  selectizeInput('animal_type', label = NULL, 
                                 choices = unique(animal_complaints_rspca$animal),
                                 multiple = TRUE,
                                 options = list(placeholder = "Select Animal Type")),
                  
                  selectizeInput('complaint_type', label = NULL, 
                                 choices = unique(animal_complaints_rspca$complaint), 
                                 multiple = TRUE,
                                 options = list(placeholder = "Select Complaint Type",
                                                onInitialize = I('function() { this.setValue(""); }')))
    )
)

#Server function call
server <- function(input, output, session) {
    
    classData <- reactive({
        animal_complaints_rspca %>%
            filter(animal %in% input$animal_type)
    })
    
    filteredData <- reactive({
        classData()[classData()$year_quarter >= input$range[1] & 
                        classData()$year_quarter <= input$range[2],]
    })
    
    subsetData <- reactive({
        classData()%>% 
            filter(complaint %in% input$complaint_type)
    })
    
    filteredSubsetData <- reactive({
        subsetData()[subsetData()$year_quarter >= input$range[1] & 
                         subsetData()$year_quarter <= input$range[2],]
    })
    
    #renders the static leaflet map ~ nothing that changes
    output$lmap <- renderLeaflet(
        leaflet(animal_complaints_rspca) %>% 
            addProviderTiles(provider = "Esri.WorldGrayCanvas") %>%
            #fitBounds(~min(lon)+0.5, ~min(lat) +0.5, ~max(lon), ~max(lat)) %>%
            setView(lng = 137.4219949, lat = -25.8570246, zoom = 5) %>% 
            addResetMapButton()
    )
    
    observe({
        #2nd level proxy that renders the animal data  
        leafletProxy("lmap", data = filteredData()) %>%
            clearShapes() %>%
            addCircles(lng = ~lon, lat = ~lat, 
                       radius = ~animal_count * 50, weight = 1,
                       color = ~colour, fillColor = ~complaint_colour,
                       fillOpacity = 0.3, popup = ~paste(suburb, animal_count, complaint, "Complaints"))
    })
    
    #expression filters the choices available in the selectInput('name')
    observe({
        updateSelectizeInput(session, "complaint_type", choices = unique(classData()$complaint))
    })
    
    #leaflet map observer / proxy for filtered subset data
    observe({
        leafletProxy("lmap", data = filteredSubsetData()) %>%
            clearShapes() %>%
            addCircles(lng = ~lon, lat = ~lat, radius = ~animal_count * 50, weight = 1,
                       color = ~colour, fillColor = ~complaint_colour,
                       fillOpacity = 0.3, popup = ~paste(suburb, animal_count, complaint, "Complaints"))
    })
    
}

shinyApp(ui = ui, server = server)