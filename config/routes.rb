Rails.application.routes.draw do
  root to: 'records#index'

  get 'import', to: 'import#index'
  post 'import/quora', to: 'import#quora'
  post 'import/stackexchange', to: 'import#stackexchange'
  post 'import/stackexchange_data', to: 'import#stackexchange_data'
  post 'import/plugin/:plugin', to: 'import#plugin', as: 'import_plugin'

  resources :records, only: [:index, :show] do
    collection do
      put 'select_action'
    end

    member do
      get 'toggle_status'
      get 'toggle_collection'
      post 'save_record_value'
    end
  end

  post 'records', to: 'records#index'

  resources :collections do
    member do
      get 'update_filter'
      get 'export'
      get 'table'
      get 'records'
      post 'drop_records'
      get 'special_export_index'
      post 'special_export'
      get 'record/:record_id', action: :record, as: 'record'
    end
  end

  resources :examples, only: [:index] do
    collection do
      get 'question_similarity'
    end
  end

  resources :transformations, only: [:index] do
    collection do
      get 'run'
    end
  end

  resources :schemas

  resources :jobs, only: [:index]
end
