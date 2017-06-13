require 'rspec' 
require_relative '../model/evento'
require_relative '../model/calendario'
require_relative '../model/recurrenciaEvento'
require_relative '../model/generarRecurrencia'
require_relative '../model/validadorDeEvento'

require 'json'

describe 'ControllerCalendarios' do

  let(:generador) { GenerarRecurrencia.new}
  let(:validador) {ValidadorDeEvento.new}
  let (:calendario) {Calendario.new("Laboral")}
  let(:evento1) { Evento.new("aydo01","Aydoo",Time.new("2017", "01","19","01","00"), Time.new("2017", "01","19","23","30"),  calendario) } 
  let(:evento2) { Evento.new("aydo02","Aydoo",Time.new("2017", "01","19","11","00"), Time.new("2017", "01","19","13","00"),  calendario) } 
  let(:evento3) { Evento.new("aydo03","Aydoo",Time.new("2017", "01","19","09","00"), Time.new("2017", "01","19","12","00"),  calendario) } 
  let(:evento4) { Evento.new("aydo04","Aydoo",Time.new("2017", "01","19","12","30"), Time.new("2017", "01","19","15","30"),  calendario) } 
  
   it "Si valido entre evento aydo03 y aydo04 obtengo true" do
    result = validador.validarEvento(evento3,evento4)  
    expect(result).to eq true
  end
  
  it "Si valido entre evento aydo01 y aydo02 obtengo exception" do
    #CASO D
    expect{validador.validarEvento(evento1,evento2)}.to raise_error(NameError)
  end
  
  it "Si valido entre evento aydo01 y aydo02 obtengo exception" do
    #CASO B
    expect{validador.validarEvento(evento2,evento1)}.to raise_error(NameError)
  end
  
  it "Si valido entre evento aydo02 y aydo03 obtengo exception" do
    #CASO A
    expect{validador.validarEvento(evento2,evento3)}.to raise_error(NameError)
  end
  
  it "Si valido entre evento aydo02 y aydo04 obtengo exception" do
    #CASO C
    expect{validador.validarEvento(evento2,evento4)}.to raise_error(NameError)
  end
  
  it "Si genero recurrencia diaria por 2 dias para aydo01 tengo que obtener 2 eventos" do
    
    frecuencia = Frecuencia.new("Diaria",1)
    
    fechaFin = Time.new("2017", "01","22","01","00")
    
    recurrenciaEvento = Recurrencia.new(fechaFin,frecuencia)
    
    calendario.agregarEvento(evento4)
    
    result = generador.crearEventosRecurrentes(calendario,evento4,recurrenciaEvento)
    
    expect(result.size).to eq 2
  end
  
    it "Si genero recurrencia diaria por 7 dias para aydo01 tengo que obtener 7 eventos" do
    
    frecuencia = Frecuencia.new("Diaria",1)
    
    fechaFin = Time.new("2017", "01","27","01","00")
    
    recurrenciaEvento = Recurrencia.new(fechaFin,frecuencia)
    
    calendario.agregarEvento(evento4)
    
    result = generador.crearEventosRecurrentes(calendario,evento4,recurrenciaEvento)
    
    expect(result.size).to eq 7
  end

  
end