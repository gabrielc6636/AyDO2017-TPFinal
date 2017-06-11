require_relative '../model/evento'

class Calendario  
 
  attr_accessor :eventos
  attr_accessor :nombre

  def initialize (nombre)  
    self.nombre = nombre 
    self.eventos = {}
  end   

  def agregarEvento(nuevoEvento)   	
  	self.eventos[nuevoEvento.nombre] = nuevoEvento
  end

  def obtenerEvento(id_evento)
  	return self.eventos[id_evento]
  end
  
  def actualizarEvento (id_evento,nuevoInicio, nuevoFin)
    evento = obtenerEvento(id_evento)
    evento.actualizarEvento(nuevoInicio, nuevoFin)
    agregarEvento(evento)
  end
  
  def obtenerEventos()
  	return self.eventos.values
  end

  def estaEvento?(id_evento)
  	return self.eventos.key? id_evento
  end

  def crearEvento(nombreEvento, nuevoInicio, nuevoFin)
      id_evento = nombreEvento.downcase      
      evento = Evento.new(id_evento, nuevoInicio, nuevoFin, self)
      agregarEvento(evento); 
  end
  
  def eliminarEvento(nombreEvento)
    self.eventos.delete(nombreCalendario)
  end
 
end