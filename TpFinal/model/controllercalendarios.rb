  require_relative '../model/calendario'
  require_relative '../model/recurrenciaEvento'
  require_relative '../model/repositorioCalendarios'
  require_relative '../model/persistidorDeDatos'
  require_relative '../model/jsonCalendario'
  require_relative '../model/jsonEvento'
  require_relative '../model/validadorDeJson'
  require_relative '../model/validadorDeCalendario'
  require_relative '../model/validadorDeEvento'
  require_relative '../model/convertidorStringAFechaTiempo'
  require 'json'

  class ControllerCalendarios

    attr_accessor :repositoriocalendarios
    attr_accessor :persistidorDeDatos
    attr_accessor :validadorDeJson
    attr_accessor :validadorCalendario
    attr_accessor :validadorEvento
    attr_accessor :frecuencias

    def initialize()  
      inicializarRepositorio()
      inicializarFrecuencias()
      self.validadorCalendario = ValidadorDeCalendario.new
      self.validadorEvento = ValidadorDeEvento.new
      self.validadorDeJson = ValidadorDeJSON.new
    end

    def inicializarRepositorio
      self.repositoriocalendarios = RepositorioCalendarios.new    
      self.persistidorDeDatos = PersistidorDeDatos.new

      self.persistidorDeDatos.cargarDatosCalendarios(self.repositoriocalendarios) 
    end

    def inicializarFrecuencias
      self.frecuencias = {}
      self.frecuencias['diaria'] = Frecuencia.new('diaria',1)
      self.frecuencias['semanal'] = Frecuencia.new('semanal',7)
      self.frecuencias['quincenal'] = Frecuencia.new('quincenal',15)
      self.frecuencias['mensual'] = Frecuencia.new('mensual',30)
    end
    
    def crearCalendario(datos_json)
     
      jsonCalendario = JsonCalendario.new(datos_json)
      nombreCalendario = jsonCalendario.obtenerNombreCalendario()

      validadorCalendario.existe_calendario(self.repositoriocalendarios,nombreCalendario)
      calendario = self.repositoriocalendarios.crearCalendario(nombreCalendario)
      persistidorDeDatos.guardarDatosRepositorioCalendarios(self.repositoriocalendarios)
      
      return calendario
    end
    
    def obtenerCalendario(nombreCalendario)
      calendario = self.repositoriocalendarios.obtenerCalendario(nombreCalendario)
      return calendario
    end
    
    def obtenerCalendarios()
      return self.repositoriocalendarios.obtenerCalendarios()
    end
    
    def eliminarCalendario(nombreCalendario)
      self.repositoriocalendarios.eliminarCalendario(nombreCalendario)
      self.persistidorDeDatos.eliminarCalendario(nombreCalendario)
    end
    
    def crearEvento(datos_json)
        validadorDeJson.validar_parametros_evento(datos_json)
        jsonEvento = JsonEvento.new(datos_json)   
        nombreCalendario = jsonEvento.obtenerNombreCalendario().downcase     
      
        validadorCalendario.no_existe_calendario(self.repositoriocalendarios,nombreCalendario)
        calendario = self.repositoriocalendarios.obtenerCalendario(nombreCalendario)
        idEvento = jsonEvento.obtenerIdEvento().downcase
        inicio = convertirStringATime(jsonEvento.obtenerFechaInicio())
        fin = convertirStringATime(jsonEvento.obtenerFechaFin())
        validadorEvento.validarExisteEvento(idEvento.downcase,calendario)
        validadorEvento.validarDuracionEvento(inicio, fin)
        calendario.crearEvento(idEvento,jsonEvento.obtenerNombreEvento(),inicio,fin)    
        if (jsonEvento.tieneRecurrencia?)
          frecuencia = jsonEvento.obtenerFrecuenciaDeRecurrencia()
          frecuencia = self.frecuencias[frecuencia]
          finRecurrencia = convertirStringATime(jsonEvento.obtenerFinDeRecurrencia())
          recurrencia = Recurrencia.new(finRecurrencia,frecuencia)
          calendario.crearEventoRecurrente(idEvento,recurrencia)
        end 

        self.repositoriocalendarios.agregarCalendario(calendario)
        persistidorDeDatos.guardarDatosRepositorioCalendarios(self.repositoriocalendarios)
    end

    def actualizarEvento(datos_json)
        validadorDeJson.validar_parametros_actualizacion_evento(datos_json)
        jsonEvento = JsonEvento.new(datos_json)
        id_calendario = jsonEvento.obtenerNombreCalendario().downcase
        inicio = jsonEvento.obtenerFechaInicio()
        fin = jsonEvento.obtenerFechaFin()        
        validadorCalendario.no_existe_calendario(self.repositoriocalendarios, id_calendario)
        calendario = self.repositoriocalendarios.obtenerCalendario(id_calendario)        
        evento = calendario.obtenerEvento(jsonEvento.obtenerIdEvento().downcase)
        validadorEvento.validarActualizacionEvento(evento)                  

        actualizar = !(inicio.nil?) || !(fin.nil?)
        if actualizar          
          inicio = setearFecha(inicio, evento)
          fin = setearFecha(fin, evento)

          validadorEvento.validarDuracionEvento(inicio, fin)
          evento.actualizarEvento(inicio,fin)
          persistidorDeDatos.guardarDatosRepositorioCalendarios(self.repositoriocalendarios);
        end

        return actualizar
    end

    def setearFecha(stringFecha, evento)
      fecha = evento.inicio

      if !(stringFecha.nil?)          
           fecha = convertirStringATime(stringFecha)
      end

      return fecha
    end

    def eliminarEvento(id_calendario, id_evento)        
        validadorCalendario.no_existe_calendario(self.repositoriocalendarios,id_calendario)
        calendario = self.repositoriocalendarios.obtenerCalendario(id_calendario)        
        validadorEvento.validarNoExisteEvento(id_evento,calendario)
        calendario.eliminarEvento(id_evento)
  
        persistidorDeDatos.guardarDatosRepositorioCalendarios(self.repositoriocalendarios);
    end
    
    def obtenerEvento(nombreEvento)  
      eventos = obtenerTodosLosEventos()

      evento = eventos.select{|evento| evento.id == nombreEvento}

      return evento
    end
    
    def obtenerEventos(nombreCalendario)
      eventos = obtenerTodosLosEventos();

      if !nombreCalendario.nil?
        validadorCalendario.no_existe_calendario(self.repositoriocalendarios,nombreCalendario)
        calendario = self.repositoriocalendarios.obtenerCalendario(nombreCalendario)
        eventos = calendario.obtenerEventos()
      end
      return eventos
    end

    def obtenerTodosLosEventos()
      calendarios = self.repositoriocalendarios.obtenerCalendarios()
      eventos = []
      contador = 0;

      calendarios.each do |calendario|
        calendario.obtenerEventos.each do |evento|
          eventos[contador] = evento
          contador = contador + 1
        end
      end

      return eventos
    end

  end