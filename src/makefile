
#compile setting
CC = nvcc
FLAGS = -O2 
SRCS = $(wildcard *.cu)
OBJECTS = $(patsubst %.cu, %.o, $(SRCS))
EXCU = gsi
LIB	=  -lcurand -lcufft
gsi: $(OBJECTS)
	$(CC) $(FLAGS) -o $(EXCU)  $(OBJECTS) $(LIB) 
dynamics_cores.o: dynamics_cores.cu pub.h ./log_error.h ./../include/datamain.th dynamics.h dynamics_cores.h
	$(CC) $(FLAGS) -c $< -o $@
dynamics.o: dynamics.cu pub.h ./log_error.h ./../include/datamain.th dynamics.h
	$(CC) $(FLAGS) -c $< -o $@
dynamics_mart.o: dynamics_mart.cu pub.h ./log_error.h ./../include/datamain.th random.h gtensorb.h dynamics.h dynamics_mart.h
	$(CC) $(FLAGS) -c $< -o $@
dynamics_multi.o: dynamics_multi.cu pub.h ./log_error.h ./../include/datamain.th dynamics.h dynamics_multi.h
	$(CC) $(FLAGS) -c $< -o $@
dynamics_pow.o: dynamics_pow.cu pub.h ./log_error.h ./../include/datamain.th dynamics.h dynamics_pow.h
	$(CC) $(FLAGS) -c $< -o $@
dynamics_precipitate.o: dynamics_precipitate.cu pub.h ./log_error.h ./../include/datamain.th dynamics.h random.h gtensorb.h dynamics_precipitate.h
	$(CC) $(FLAGS) -c $< -o $@
dynamics_stress.o: dynamics_stress.cu pub.h ./log_error.h ./../include/datamain.th dynamics.h random.h gtensorb.h dynamics_stress.h
	$(CC) $(FLAGS) -c $< -o $@
dynamics_xxx.o: dynamics_xxx.cu pub.h ./log_error.h ./../include/datamain.th dynamics.h dynamics_xxx.h
	$(CC) $(FLAGS) -c $< -o $@
gs.o: gs.cu pub.h ./log_error.h ./../include/datamain.th pub_main.h ./../include/datamain.th ./variable.h ./gtensorb.h ./random.h ./dynamics.h ./dynamics_cores.h ./dynamics_mart.h ./dynamics_multi.h ./dynamics_pow.h ./dynamics_precipitate.h ./dynamics_stress.h ./dynamics_xxx.h ./gs.h
	$(CC) $(FLAGS) -c $< -o $@
gtensorb.o: gtensorb.cu ../include/datamain.th ../include/datanumbers.th ../include/datamath.th ../include/datatemp.th ../include/datamap.th gtensorb.h
	$(CC) $(FLAGS) -c $< -o $@
input.o: input.cu pub.h ./log_error.h ./../include/datamain.th pub_main.h ./../include/datamain.th ./variable.h ./gtensorb.h ./random.h ./dynamics.h ./dynamics_cores.h ./dynamics_mart.h ./dynamics_multi.h ./dynamics_pow.h ./dynamics_precipitate.h ./dynamics_stress.h ./dynamics_xxx.h ./gs.h input.h
	$(CC) $(FLAGS) -c $< -o $@
main.o: main.cu pub.h ./log_error.h ./../include/datamain.th pub_main.h ./../include/datamain.th ./variable.h ./gtensorb.h ./random.h ./dynamics.h ./dynamics_cores.h ./dynamics_mart.h ./dynamics_multi.h ./dynamics_pow.h ./dynamics_precipitate.h ./dynamics_stress.h ./dynamics_xxx.h ./gs.h input.h
	$(CC) $(FLAGS) -c $< -o $@
random.o: random.cu ../include/datamain.th ../include/datanumbers.th ../include/datamath.th ../include/datatemp.th ../include/datamap.th random.h
	$(CC) $(FLAGS) -c $< -o $@
variable.o: variable.cu pub.h ./log_error.h ./../include/datamain.th ../include/datamain.th ../include/datanumbers.th ../include/datamath.th ../include/datatemp.th ../include/datamap.th variable.h
	$(CC) $(FLAGS) -c $< -o $@

clean:
	rm *.o
	rm $(EXCU)
install:
	cp $(EXCU) /public/home/Eins/bin/

