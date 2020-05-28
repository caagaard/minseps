from sage.combinat.permutation import Permutation
import itertools
import re
import time

def makeAllGraphs(V,E):
        tempGraphs=[]
        allGraphs=[]
        if V==1 and E==1:
                G = Graph(1,loops=True, multiedges=True)
                G.add_edge((0,0,1))
                tempGraphs.append(G)
        pos_edges = list(itertools.combinations_with_replacement(range(0,V),2))
        edge_choices = list(itertools.combinations_with_replacement(pos_edges, E))
        for choice in edge_choices:
                labelled_choice= []
                for i in range(0,len(choice)):
                        labelled = choice[i]+(i+1,)
                        labelled_choice.append(labelled)
                new_graph = Graph(V, loops=True, multiedges=True)
                new_graph.add_edges(labelled_choice)
                pass_flag=0
                if new_graph.is_connected():
                        pass_flag=1
                deg_seq= new_graph.degree_sequence()
                if min(deg_seq)==0:
                        pass_flag = 0
                i=0
                while pass_flag==1 and i<V:
                        if new_graph.degree(i)%2 ==1:
                                pass_flag=0
                        if new_graph.degree(i) ==2 and new_graph.neighbors(i) != [i]:
                                pass_flag=0
                        i = i+1
                if pass_flag==1:
                        tempGraphs.append(new_graph)

        if len(tempGraphs)==0:
                return([])
        allGraphs.append(tempGraphs[0])
        for graph in tempGraphs:
                pass_flag =1
                i=0
                while pass_flag== 1 and i<len(allGraphs):
                        if graph.is_isomorphic(allGraphs[i]):
                                pass_flag=0
                        i=i+1
                if pass_flag ==1:
                        allGraphs.append(graph)
        return(allGraphs)

def makeRotSys(graph,g):
        e = len(graph.edges())
        v= len(graph.vertices())
        epsilon=[]
        for i in range(1,e+1):
                epsilon.append((2*i-1,2*i))
        epsilon = Permutation(epsilon)
        perms = []
        for i in range(0,len(graph.vertices())):
                edges = graph.edges_incident(i)
                edges_i=[]
                for edge in edges:
                        if edge[0] == i:
                                edges_i.append(2*edge[2]-1)
                        if edge[1] == i:
                                edges_i.append(2*edge[2])
                perms.append(itertools.permutations(edges_i))
        # For every way to pick one perm from each vertex
        found_system= 0
        systems = itertools.product(*perms)
        # want to make a rotation system from each selection of permutations
        for system in systems:
                # Plan:
                # Convert the permutation of edges at each vertex to integers matching endpoints
                # cast as permutation
                permstring=''
                for vert in system:
                        permstring= permstring+str(vert)
                nu = Permutation(permstring)
                theta = nu.right_action_product(epsilon)
                failed_cycles=0
                for cycle in theta.to_cycles():
                        for i in cycle:
                                if i%2 == 1 and i+1 in cycle:
                                        failed_cycles=1
                if failed_cycles == 0:
                        if 2+2*g == e-v + len(theta.to_cycles()):
                                found_system=1
                if found_system==1:
                        return(True)
        return(False)


#print(makeAllGraphs(1,3))

final_list=[]
max_g = 3
total_time= time.time()
#Prepare graph lists here:
all_graphs=[]
for v in range(1,2*max_g+1):
        start=time.time()
        graphs_on_v_verts =[]
        for e in range(1, v+2*max_g+1):
                graphs_on_v_verts.append(makeAllGraphs(v,e))
                if v==1 and e==1:
                        print(graphs_on_v_verts)
        all_graphs.append(graphs_on_v_verts)
        end=time.time()
        print('time to make graphs on '+str(v)+' vertices - ' + str(end-start))

for g in range(0, max_g+1):
        start=time.time()
        filename = 'genus_'+str(g)+'_outputs.txt'
        out_file= open(filename, 'w')
        out_file.write('Graphs of genus ' +str(g))
        ticker = 0
        for v in range(1,2*g+1):
                v_timer=time.time()
                out_file.write(' with '+str(v)+' vertices')
                for e in range(1,v+2*g+1):
                        out_file.write(' and '+str(e)+ ' edges \n')
                        for graph in all_graphs[v-1][e-1]:
                               if makeRotSys(graph,g):
                                        out_file.write(str(graph.adjacency_matrix())+'\n')
                                        ticker = ticker+1
                v_end = time.time()
                print('Time to compute genus = '+str(g) +', vertices = '+str(v)+' was '+str(v_end-v_timer))
        print('Genus = '+str(g) + ' Number of graphs = ' +str(ticker))
        end=time.time()
        print('Genus = '+str(g)+' took '+str(end-start) + ' seconds ')
end_total=time.time()
print('Took '+str(end_total-total_time))
