library(plumber)
library(xgboost)
library(jsonlite)


prefix <- '/opt/ml/'
model_path <- paste0(prefix, 'model/xgb.model')

model <- xgb.load(model_path)
print("Loaded model successfully")

# function to use our model. You may require to transform data to make compatible with model
inference <- function(input_data){
  ds <- xgb.DMatrix(data = input_data )
  output <- predict(model, ds)
  list(output=output)
}

# Setup scoring function
serve <- function() {
  app <- plumb(paste0(prefix,'endpoints.R'))
  print(app)
  app$run(host='0.0.0.0', port=8080)
}

# Run at start-up
args <- commandArgs()
#if (any(grepl('train', args))) {
#  train()
#}
if (any(grepl('serve', args))) {
  serve()
}
