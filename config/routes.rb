Rails.application.routes.draw do
  root  'users#index'
  get   '/error'            , to: 'users#error'   , as: 'query_error'
  get   '/populars/:page'   , to: 'users#most'    , as: 'most_popular_users'
  post  '/search'           , to: 'users#search'  , as: 'user_search'
  get   '/:username'        , to: 'users#show'    , as: 'user_show'
  get   '/:username/line'   , to: 'users#line'    , as: 'user_line'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
