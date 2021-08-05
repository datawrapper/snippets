ellipse.jitter <- function(x,y,radius,scale.major,scale.minor) {
  x.jitter <- radius*scale.major
  y.jitter <- radius*scale.minor
  while((x.jitter*scale.minor*radius)^2 + 
        (y.jitter*scale.major*radius)^2 -
        (scale.major*radius*scale.minor*radius)^2 > 0) {
    x.jitter <- runif(1,-radius*scale.major,radius*scale.major)
    y.jitter <- runif(1,-radius*scale.minor,radius*scale.minor)
  }
  return(data.frame('x.jittered' = x + x.jitter, 'y.jittered' =y + y.jitter))
}


jitter.dataframe <- function(dataframe,x.column,y.column,radius.column,scale.major,scale.minor){
  jitters <- data.frame('x.jittered' = numeric(0), 'y.jittered' = numeric(0))
  for (i in 1:nrow(dataframe)) {
    point <- slice(dataframe,i)
    coordinates.jittered <- ellipse.jitter(pull(point,x.column), pull(point,y.column), pull(point,radius.column), scale.major, scale.minor)
    jitters <- bind_rows(jitters,coordinates.jittered)
  }
  dataframe <- bind_cols(dataframe,jitters)
  return(dataframe)
}
