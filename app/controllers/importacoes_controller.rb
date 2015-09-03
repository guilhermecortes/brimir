class Admin::ImportacoesController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource :class => Admin::ImportacoesController
    # skip_before_filter :verify_authenticity_token, :only => [:busca_agenda]

    # this specifies that the test_ssl controller will be the only one using SSL
    #force_ssl :only => [:index] unless Rails.env.development?

    def index
        #logger.info "###################Processing the request..."
    end

    def upload

        if params[:comprador].blank? && params[:mercadologico].blank? && params[:comprador_mercadologico].blank? && params[:fornecedor_mercadologico].blank? && params[:fornecedor].blank?
            respond_to do |format|
                flash[:notice] = 'Importacao-sem-arquivos'
                format.html { redirect_to admin_importar_arquivos_path }
            end
        else
            #Importar comprador ---------------
            unless params[:comprador].blank?
                uploader_comprador = AttachmentUploader.new #instancio objeto para receber arquivo do upload
                uploader_comprador.cache!(params[:comprador]) #salva o arquivo no upload no cache
                #chama método de importar passando o arquivo que fez upload e o caminho onde ele está
                importar_comprador uploader_comprador, "#{Rails.root}/public/uploads/temp_arquivos_fornecedores/#{uploader_comprador.cache_name}"
            end
            #Importar comprador ---------------

            #Importar mercadológico ---------------
            unless params[:mercadologico].blank?
                uploader_mercadologico = AttachmentUploader.new #instancio objeto para receber arquivo do upload
                uploader_mercadologico.cache!(params[:mercadologico]) #salva o arquivo no upload no cache
                #chama método de importar passando o arquivo que fez upload e o caminho onde ele está
                importar_mercadologico uploader_mercadologico, "#{Rails.root}/public/uploads/temp_arquivos_fornecedores/#{uploader_mercadologico.cache_name}"
            end
            #Importar mercadológico ---------------

            #Importar comprador-mercadológico ---------------
            unless params[:comprador_mercadologico].blank?
                uploader_comprador_mercad = AttachmentUploader.new #instancio objeto para receber arquivo do upload
                uploader_comprador_mercad.cache!(params[:comprador_mercadologico]) #salva o arquivo no upload no cache
                #chama método de importar passando o arquivo que fez upload e o caminho onde ele está
                importar_comprador_mercad uploader_comprador_mercad, "#{Rails.root}/public/uploads/temp_arquivos_fornecedores/#{uploader_comprador_mercad.cache_name}"
            end
            #Importar comprador-mercadológico ---------------

            #Importar fornecedor-mercadológico ---------------
            unless params[:fornecedor_mercadologico].blank?
                uploader_fornecedor_mercad = AttachmentUploader.new #instancio objeto para receber arquivo do upload
                uploader_fornecedor_mercad.cache!(params[:fornecedor_mercadologico]) #salva o arquivo no upload no cache
                #chama método de importar passando o arquivo que fez upload e o caminho onde ele está
                importar_fornecedor_mercad uploader_fornecedor_mercad, "#{Rails.root}/public/uploads/temp_arquivos_fornecedores/#{uploader_fornecedor_mercad.cache_name}"
            end
            #Importar fornecedor-mercadológico ---------------

            #Importar fornecedores para a tabela temporária ---------------
            unless params[:fornecedor].blank?
                uploader_fornecedor = AttachmentUploader.new #instancio objeto para receber arquivo do upload
                uploader_fornecedor.cache!(params[:fornecedor]) #salva o arquivo no upload no cache
                #chama método de importar passando o arquivo que fez upload e o caminho onde ele está
                importar_fornecedor uploader_fornecedor, "#{Rails.root}/public/uploads/temp_arquivos_fornecedores/#{uploader_fornecedor.cache_name}"
            end
            #Importar fornecedores para a tabela temporária ---------------

            respond_to do |format|
                flash[:notice] = 'Importacao-sucesso'
                format.html { redirect_to admin_importar_arquivos_path }
            end
        end
    end

    #método de importar compradores
    def importar_comprador uploader, path

        if Admin::Comprador.all.delete_all #deleta todos os registros
            compradores = File.open(path, "r").map do |line| #ler cada linha do arquivo
                id, nome = line.strip.split("|") #separa os campos do arquivo
                Admin::Comprador.new(:id => id, :nome => nome) #cria objeto com os campos do arquivo
            end
            Admin::Comprador.import compradores #chama método import da gem para realizar o bulk

            uploader.retrieve_from_cache!(uploader.cache_name) #exclui do cache o arquivo que foi feito upload
            uploader.remove! #exclui do cache o arquivo que foi feito upload
        end

    end

    #método de importar mercadológico
    def importar_mercadologico uploader, path

        if Admin::Mercadologico.all.delete_all #deleta todos os registros
            mercadologicos = File.open(path, "r").map do |line| #ler cada linha do arquivo
                id, nome = line.strip.split("|") #separa os campos do arquivo
                Admin::Mercadologico.new(:id => id, :nome => nome) #cria objeto com os campos do arquivo
            end
            Admin::Mercadologico.import mercadologicos #chama método import da gem para realizar o bulk

            uploader.retrieve_from_cache!(uploader.cache_name) #exclui do cache o arquivo que foi feito upload
            uploader.remove! #exclui do cache o arquivo que foi feito upload
        end

    end

    #método de importar comprador-mercadológico
    def importar_comprador_mercad uploader, path

        if Admin::CompradoresMercadologicos.all.delete_all #deleta todos os registros
            comprador_mercadologicos = File.open(path, "r").map do |line| #ler cada linha do arquivo
                admin_mercadologico_id, admin_comprador_id = line.strip.split("|") #separa os campos do arquivo
                Admin::CompradoresMercadologicos.new(:admin_comprador_id => admin_comprador_id, :admin_mercadologico_id => admin_mercadologico_id) #cria objeto com os campos do arquivo
            end
            Admin::CompradoresMercadologicos.import comprador_mercadologicos #chama método import da gem para realizar o bulk

            uploader.retrieve_from_cache!(uploader.cache_name) #exclui do cache o arquivo que foi feito upload
            uploader.remove! #exclui do cache o arquivo que foi feito upload
        end

    end

    #método de importar fornecedor-mercadológico
    def importar_fornecedor_mercad uploader, path

        if Admin::FornecedoresMercadologicos.all.delete_all #deleta todos os registros
            fornecedor_mercadologicos = File.open(path, "r").map do |line| #ler cada linha do arquivo
                admin_fornecedor_id, admin_mercadologico_id = line.strip.split("|") #separa os campos do arquivo
                Admin::FornecedoresMercadologicos.new(:admin_fornecedor_id => admin_fornecedor_id, :admin_mercadologico_id => admin_mercadologico_id) #cria objeto com os campos do arquivo
            end
            Admin::FornecedoresMercadologicos.import fornecedor_mercadologicos #chama método import da gem para realizar o bulk

            uploader.retrieve_from_cache!(uploader.cache_name) #exclui do cache o arquivo que foi feito upload
            uploader.remove! #exclui do cache o arquivo que foi feito upload
        end

    end

    #método de importar fornecedores para a tabela temporária
    def importar_fornecedor uploader, path

        if TempAdminFornecedores.all.delete_all #deleta todos os registros
            fornecedores = File.open(path, "r:ISO-8859-1").map do |line| #ler cada linha do arquivo, adicionado ISO para não dar erro de codificação UTF-8
                id, nome_fantasia, email, nome_vendedor = line.strip.split("|") #separa os campos do arquivo
                TempAdminFornecedores.new(:id => id, :nome_fantasia => nome_fantasia, :email => email, :nome_vendedor => nome_vendedor, :status => 1) #cria objeto com os campos do arquivo
            end
            TempAdminFornecedores.import fornecedores #chama método import da gem para realizar o bulk

            uploader.retrieve_from_cache!(uploader.cache_name) #exclui do cache o arquivo que foi feito upload
            uploader.remove! #exclui do cache o arquivo que foi feito upload
            atualiza_status_fornec #método para atualizar status
        end

    end

    #após importar os fornecedores para a tabela temporária, devemos fazer um merge com os já existentes
    #atualiza todos os fornecedores existentes para status = 0 (pois se não estiver na lista de importação, ele
    # será desativado).
    #Depois de atualizar para zero, atualiza status para 1 os que estão em comum na tabela temporária
    def atualiza_status_fornec
        #atualiza para zero
        str_update_0 = 'UPDATE admin_fornecedores SET status = 0'
        ActiveRecord::Base.connection.execute(str_update_0) #executa a query

        #atualiza os que estão em comum para 1
        str_update_1 = 'UPDATE admin_fornecedores
                                        LEFT OUTER JOIN  temp_admin_fornecedores ON
                                        admin_fornecedores.id = temp_admin_fornecedores.id
                                        SET admin_fornecedores.status = 1'
        ActiveRecord::Base.connection.execute(str_update_1) #executa a query
        insert_fornecedores #método para inserir fornecedores
    end

    #insere os fornecedores que estão na tabela temporária, mas não estão na tabela definitiva ainda
    def insert_fornecedores
        str_insert = 'INSERT INTO admin_fornecedores SELECT temp_admin_fornecedores.* FROM
                    admin_fornecedores RIGHT OUTER JOIN
                    temp_admin_fornecedores ON
                    admin_fornecedores.id = temp_admin_fornecedores.id WHERE
                    admin_fornecedores.id IS NULL'
        ActiveRecord::Base.connection.execute(str_insert) #executa a query
        cadastra_novos_fornecedores #método para cadastrar os novos fornecedores
    end

    #cadastra e envia email para os novos fornecedores importados
    def cadastra_novos_fornecedores
        fornecedores = Admin::Fornecedor.where("created_at >= '#{Date.today}'") #lista os novos fornecedores cadastrados
        Thread.new do #faz o cadastro e envio de e-mail em background
            fornecedores.each_with_index do |fornecedor, index|
                # p "=============================== #{fornecedor.id}"
                User.create!(:roles_mask => 2,
                             :password => "#{fornecedor.id}ca2015",
                             :password_confirmation => "#{fornecedor.id}ca2015",
                             :admin_fornecedor_id => fornecedor.id)
                EnviaEmail.envia_login_fornecedor(fornecedor, fornecedor.email).deliver
                # p "=============================== #{fornecedor.email} - #{index}"
            end
        end
    end

end
