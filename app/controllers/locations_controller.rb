require "json"

class LocationsController < ApplicationController

  def index
    # get all locations in the table locations
    @locations = Location.all

    @locations_json = @locations.to_json
  end

  def new
    # default: render ’new’ template (\app\views\locations\new.html.haml)
  end

  def create
    # create a new instance variable called @location that holds a Location object built from the data the user submitted
    @location= Location.new(params[:location])

    # if the object saves correctly to the database
    if @location.save
      # redirect the user to index
      redirect_to locations_path, notice: 'Location was successfully created.'
    else
      # redirect the user to the new method
      render action: 'new'
    end
  end

  def edit
    # find only the location that has the id defined in params[:id]
    @location = Location.find(params[:id])
  end

  def update
    # find only the location that has the id defined in params[:id]
    @location = Location.find(params[:id])

    # if the object saves correctly to the database
    if @location.update_attributes(params[:location])
      # redirect the user to index
      redirect_to locations_path, notice: 'Location was successfully updated.'
    else
      # redirect the user to the edit method
      render action: 'edit'
    end
  end

  def destroy
    # find only the location that has the id defined in params[:id]
    @location = Location.find(params[:id])

    # delete the location object and any child objects associated with it
    @location.destroy

    # redirect the user to index
    redirect_to locations_path, notice: 'Location was successfully deleted.'
  end

  def destroy_all
    # delete all location objects and any child objects associated with them
    Location.destroy_all

    # redirect the user to index
    redirect_to locations_path, notice: 'All locations were successfully deleted.'
  end

  def show
    # default: render ’show’ template (\app\views\locations\show.html.haml)
    @location = Location.find(params[:location])
  end

  def input
    # El usuario podrá ingresar una coordenada geográfica (latitud y longitud)
    # para que la aplicación determine si ésta se encuentra dentro de alguna ubicación
    # de interés en la base de datos, mostrando también la información de ésta(s) última(s).
    #si no ha mandado coordenadas

      @locations = Location.all
      @locationParam = Location.new(params[:location])

      if !params[:user].nil?
        @vec = where?(@locationParam, @locations)
      end

  end

  def upload

    @locations = Location.all
    #En el punto 1 el usuario ingresa una coordenada y la aplicación determina si se encuentra dentro de
    #alguna ubicación de interés. Ahora queremos que el usuario pueda subir un archivo JSON que la aplicación deberá
    #decodificar y utilizar como fuente de una ruta de datos de la persona. La aplicación determinará a qué ubicaciones
    #de interés fue el usuario. En los anexos viene un ejemplo del contenido de estos archivos.

    if !params[:file].nil?
      @file=params[:file]

      #validar que sean archivos .json
      chkNameFile=@file.original_filename.split(/\./)
      if chkNameFile[1]=="json"
        #guardar el archivo en un archivo temporar
        f = @file.tempfile.to_path

        #convertir al archivo en un arreglo de hash donde cada hash es un objeto json
        mylocJson = JSON.parse(File.read(f))

        myLoc=[]

        #@myLoc contiene todas las hash en forma de locaciones
        mylocJson.each do |l1|
         myLoc[myLoc.length]=(Location.new("latitude"=>l1["latitude"] , "longitude"=>l1["longitude"] , "name"=>l1["timestamp"]))
        end

        #Comparar a que ubicación de las ubicaciones contenidas en json vs las de la bd
        @vec =[]

        myLoc.each do |l1|
          @vec = @vec + (where?(l1,@locations))
        end

      else
        redirect_to locations_upload_path(params[:id]), notice: 'Just .json Files.'
      end

    end





  end

  def convex
    #Calcular casco convexo y perímetro de éste, a partir de un grupo de ubicaciones de interés.
    @locations = Location.all
    @convexPoints = ConvexHul.calculate (@locations)

    # También debe mostrarse el perímetro  de dicha área,
    @perimeter = perimeter(@convexPoints)

    #la distancia entre la casa del usuario y la ubicación visitada más alejada
     @home = getHome(@locations)
     @locmax = far_distance(@home,@locations)
  end

  def getHome(locations)
    home= nil
    locations.each do|l1|
      if l1.name.downcase=="home"
        home=l1
      end
    end
   return home

  end

  def cal_distance (l1,l2)
    r = 6371   #distancia del radio de la tierra en km

    deltaLat = toRadians (l2.latitude-l1.latitude)
    deltaLon = toRadians (l2.longitude-l1.longitude)

    lat1 = toRadians(l1.latitude)
    lat2 = toRadians(l2.latitude)

    a = Math.sin(deltaLat/2)*Math.sin(deltaLat/2)+
        Math.cos(lat1)*Math.cos(lat2)*
            Math.sin(deltaLon/2)*Math.sin(deltaLon/2)

    c = 2*Math.atan2(Math.sqrt(a),Math.sqrt(1-a))
    d = r*c*1000

  end

  def toRadians (degree)
    degree*Math::PI/180
  end

  def where?(l1 , locations , r=100)
    v = []
    locations.each do |l2|
      if cal_distance(l1,l2)<=r
        v[v.length]=l2
      end
    end
    return v
  end

  module ConvexHul
    # after graham & andrew
    def self.calculate(points)
      lop = points.sort_by { |p| p.latitude }
      left = lop.shift
      right = lop.pop
      lower, upper = [left], [left]
      lower_hull, upper_hull = [], []
      det_func = determinant_function(left, right)
      until lop.empty?
        p = lop.shift
        ( det_func.call(p) < 0 ? lower : upper ) << p
      end
      lower << right
      until lower.empty?
        lower_hull << lower.shift
        while (lower_hull.size >= 3) &&
            !convex?(lower_hull.last(3), true)
          last = lower_hull.pop
          lower_hull.pop
          lower_hull << last
        end
      end
      upper << right
      until upper.empty?
        upper_hull << upper.shift
        while (upper_hull.size >= 3) &&
            !convex?(upper_hull.last(3), false)
          last = upper_hull.pop
          upper_hull.pop
          upper_hull << last
        end
      end
      upper_hull.shift
      upper_hull.pop
      lower_hull + upper_hull.reverse
    end

    private

    def self.determinant_function(p0, p1)
      proc { |p| ((p0.latitude-p1.latitude)*(p.longitude-p1.longitude))-((p.latitude-p1.latitude)*(p0.longitude-p1.longitude)) }
    end

    def self.convex?(list_of_three, lower)
      p0, p1, p2 = list_of_three
      (determinant_function(p0, p2).call(p1) > 0) ^ lower
    end

  end

  def perimeter (locations)

    l2=locations[locations.length-1]
    sum=0
    locations.each do|l1|
      sum=sum+cal_distance(l2,l1)
      l2=l1

    end
    return sum

  end

  def far_distance (l2,locations)
    max=0
    lmax =l2
    locations.each do|l1|
      dis = cal_distance(l2,l1)
      if dis > max
         max=dis
         lmax=l1
      end
    end
    return lmax
  end

end
