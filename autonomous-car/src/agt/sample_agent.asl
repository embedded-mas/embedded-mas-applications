edge(a,1,front,null).
edge(b,2,front,null).
edge(c,3,front,null).
edge(g,f,front,null).
edge(9,8,front,null).
edge(10,e,front,null).
//
//edge(a,m,front,null).
//-------------
edge(1,2,left,a).
edge(1,2,right,6).

edge(2,1,right,b).
edge(2,1,left,3).

edge(1,6,right,a).
edge(1,6,left,2).

edge(2,3,right,1).
edge(2,3,left,b).

edge(3,2,right,c).
edge(3,2,left,4).

edge(2,b,left,1).
edge(2,b,right,3).

edge(3,4,right,2).
edge(3,4,left,c).

edge(4,3,right,d).
edge(4,3,left,5).

edge(3,c,left,2).
edge(3,c,right,4).

edge(4,5,right,3).
edge(4,5,left,d).

edge(4,d,left,3).
edge(4,d,right,5).

edge(d,4,right,k).
edge(d,4,left,7).

edge(5,6,right,4).
edge(5,6,left,e).

edge(5,e,left,4).
edge(5,e,right,6).

edge(e,5,right,8).
edge(e,5,left,10).

edge(6,1,right,5).
edge(6,1,left,f).

edge(6,f,left,5).
edge(6,f,right,1).

edge(d,k,left,4).
edge(d,k,right,7).

edge(d,7,right,4).
edge(d,7,left,k).

edge(5,4,left,6).
edge(5,4,right,e).

edge(e,10,right,5).
edge(e,10,left,8).

edge(e,8,left,5).
edge(e,8,right,10).

edge(8,e,right,7).
edge(8,e,left,9).

edge(8,9,right,e).
edge(8,9,left,7).

edge(8,7,left,e).
edge(8,7,right,9).

edge(7,8,right,d).
edge(7,8,left,j).

edge(7,j,right,8).
edge(7,j,left,d).

edge(j,7,left,i).

edge(7,d,left,8).
edge(7,d,right,j).

edge(k,d,right,i).

edge(k,l,left,d).

edge(l,k,right,m).

edge(l,m,left,k).

edge(m,a,left,l).

edge(a,m,right,1).

edge(f,6,left,g).
edge(f,6,right,h).

edge(f,h,right,g).
edge(f,h,left,6).

edge(h,f,right,i).

edge(6,5,left,1).
edge(6,5,right,f).

edge(h,i,left,f).

edge(i,h,right,j).

edge(i,j,left,h).

edge(j,i,right,7).

edge(m,l,right,a).


//uma aresta de X para Y indica um caminho de Y para X.
counteredge(X,Y,Direction,Previous) :- edge(Y,X,direction,previous) 
                              & X\==Y & opposite_direction(direction,Direction).

opposite_direction(front,back).
opposite_direction(back,front).
opposite_direction(left,right).
opposite_direction(right,left).

// Cranca de que pode seguir com a execução
//comm("ahead").


/* O agente conclui que pode chegar de Origem a Destino por um Caminho... */
// caminho(Origem, Destino, Caminho, Anterior) :-
//     caminho_aux(Origem, Destino, [Origem], Caminho, Anterior).

/* O agente conclui que pode chegar de Origem a Destino por um Caminho... */
caminho(Origem, Destino, Caminho, Anterior) :-
   caminho_aux(Origem, Destino, [Origem], Caminho, Anterior) &
   not (caminho_aux(Origem, Destino, [Origem], Caminho2, Anterior2) & 
   .length(Caminho,L1) & .length(Caminho2,L2) & L2<L1).

// Regra auxiliar para buscar um caminho usando recursão - caso base
caminho_aux(Destino, Destino, Caminho, Caminho, Anterior).

caminho_aux(Origem, Destino, Visitados, Caminho, Anterior) :-    
    .findall([Proximos,Direcao], edge(Origem,Proximos,Direcao,Anterior), LProximos) &
    .member([Destino, _], LProximos) &
    .concat(Visitados, [[Destino, Origem]], NVisitados) &
    caminho_aux(Destino, Destino, NVisitados, Caminho, Origem).

caminho_aux(Origem, Destino, Visitados, Caminho, Anterior) :-    
    (edge(Origem, Proximo, Direcao, Anterior) | counteredge(Origem, Proximo, Direcao, Anterior)) &
    not(.member([Proximo, _], Visitados)) &  // Verifica se o próximo nó não foi visitado ainda para evitar ciclos
    .concat(Visitados, [[Proximo, Origem]], NVisitados) &
    caminho_aux(Proximo, Destino, NVisitados, Caminho, Origem).
                             

!go_to(10,6). //Objetivo go_to(X,Y): o agente deseja ir do ponto X ao Y.


+!go_to(Origem,Destino) :  caminho(Origem,Destino,Caminho,Anterior) 
   <- .print("Vou percorrer o caminho ", Caminho);
      !percorre_caminho(Caminho);      
      .print("Cheguei ao destino").


//Planos para atingir o objetivo "percorre_caminho". Estes planos fazem o agente percorrer uma lista de pontos passados como parâmetro.

//Caso 1: A lista de pontos percorrer está vazia. Logo, não há caminho a percorrer.
+!percorre_caminho([],_) 
   <- .print("Percorri todo o caminho").

//Caso 2: O agente não tem crença a respeito da sua posição atual. Logo, ele ainda não começou o trajeto.
+!percorre_caminho([H|T]) : not posicao_atual(_)  //se o agente não tem a crença "posicao_atual", ele está no início do percurso
   <- .print("Iniciando o caminho em ", H, " (vindo de ", F, ").", T);
      +posicao_atual(H); //atualiza a posição atual
      !percorre_caminho(T).

//Caso 3: O agente está na primeira aresta.
+!percorre_caminho([[H, F]|T]) : posicao_atual(P)
                                 & edge(P,H,D,null) //verificar a direção a seguir de P para H
                                    //& comm("ahead")
   <- .print("Indo de ", P, " para ", H, " (vindo de ", null, ") - direcao: ", D);
      -+posicao_atual(H); //atualiza a posição atual
      //embedded.mas.bridges.jacamo.defaultEmbeddedInternalAction("arduino1", D, []); // envia instrucao ao Arduino
      //!wait;
      //.wait(comm("ahead")); //espera até ter a crença comm("ahead")
      !turn(D);
      !percorre_caminho(T,P).

//Caso 4: O agente está no meio do trajeto.
+!percorre_caminho([[H, F]|T], O) : posicao_atual(P)
                                 & edge(P,H,D,O) //verificar a direção a seguir de P para H
                                    //& comm("ahead")
   <- .print("Indo de ", P, " para ", H, " (vindo de ", F, ") - direcao: ", D);
      -+posicao_atual(H); //atualiza a posição atual
      !turn(D);
      !percorre_caminho(T,P).


+!turn(D) : D\==front
   <-  embedded.mas.bridges.jacamo.defaultEmbeddedInternalAction("arduino1", D, []); // envia instrucao ao Arduino 
       !wait;
       //-+comm("ahead"); //Simula crença vinda do arduino
       -comm("ahead")[device(_),source(percept)];
       .print("Tomando Decisao.");
       .wait(comm("ahead")); //espera até ter a crença comm("ahead")
       embedded.mas.bridges.jacamo.defaultEmbeddedInternalAction("arduino1", front, []); // envia instrucao ao Arduino
       !wait;
       .print("Prosseguindo.");
       -comm("ahead")[device(_),source(percept)];
       .wait(comm("ahead"));
       .print("end plan ", D).
       // teste
       //embedded.mas.bridges.jacamo.defaultEmbeddedInternalAction("arduino1", "check", []).

+!turn(D)
   <-  embedded.mas.bridges.jacamo.defaultEmbeddedInternalAction("arduino1", D, []); // envia instrucao ao Arduino 
       !wait;
       //-+comm("ahead"); //Simula crença vinda do arduino
       -comm("ahead")[device(_),source(percept)];
       .print("indo para frente.");
       .wait(comm("ahead")). //espera até ter a crença comm("ahead")
       //-comm("ahead").
       // teste
       //embedded.mas.bridges.jacamo.defaultEmbeddedInternalAction("arduino1", "check", []).
     


/*
+!percorre_caminho([H|T]): comm("wait")
   <- .print("aguardando aresta");
      -+comm("ahead");
      -+posicao_atual(H);
      !percorre_caminho(T).
*/      

/*+!wait: comm("wait") // permanece aqui ate o arduino mandar a crenca de que o caminho ja foi percorrido
   <- .print("percorrendo aresta");
      -+comm("ahead"); // aqui o arduino que enviaria essa crenca
      !wait.

+!wait: comm("ahead")
   <- !percorre_caminho(H).
   */

+!wait 
   <- .wait(200).
      //-+comm("ahead").
      

+comm("ahead")
   <- .print("recebeu ahead").

-comm("ahead")
   <- .print("perdeu ahead").