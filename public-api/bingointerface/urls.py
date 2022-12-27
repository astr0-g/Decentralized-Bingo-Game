from django.urls import path


from . import views


urlpatterns = [
    path('getbingobasicdetails/', views.api_getbingobasicdetails),
    path('getplayergameboard/<playeraddress>/<gameround>',
         views.api_getplayergameboard),
    path('getplayer/<gameround>', views.api_getplayer),
    path('getroundbingoresult/<gameround>', views.api_getroundbingoresult),
    path('checkwinner/<playeraddress>/<gameround>',
         views.api_checkwinner),
    path('get10rounddetils/',
         views.api_get10rounddetils),

]
